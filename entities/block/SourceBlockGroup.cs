using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class SourceBlockGroup : Node2D
{
    private HashSet<SourceBlock> sourceBlocks = new HashSet<SourceBlock>();
    private Area2D _mergeArea;
    private CollisionShape2D _mergeCollisionShape;
    private RectangleShape2D _mergeShape;
    private bool _isMerging = false; // 防止重复合并
    private bool _isGroupFalling = false; // 组是否正在下落
    private Tween _groupFallTween; // 组下落动画

    public SourceBlockGroup()
    {
        SetupMergeDetection();
    }

    /// <summary>
    /// 设置合并检测区域
    /// </summary>
    private void SetupMergeDetection()
    {
        // 创建 Area2D 用于检测与其他组的碰撞
        _mergeArea = new Area2D();
        _mergeArea.Name = "MergeArea";

        // 创建碰撞形状
        _mergeShape = new RectangleShape2D();
        _mergeCollisionShape = new CollisionShape2D();
        _mergeCollisionShape.Shape = _mergeShape;

        // 设置碰撞层级 - 只检测其他 SourceBlockGroup
        _mergeArea.CollisionLayer = CollisionLayers.PICKUP;
        _mergeArea.CollisionMask = CollisionLayers.PICKUP;

        // 连接信号
        _mergeArea.AreaEntered += OnMergeAreaEntered;

        // 添加到节点树
        _mergeArea.AddChild(_mergeCollisionShape);
        AddChild(_mergeArea);

        // 初始更新碰撞区域
        UpdateMergeArea();
    }

    /// <summary>
    /// 当检测到其他 SourceBlockGroup 时触发合并
    /// </summary>
    /// <param name="area">进入的区域</param>
    private void OnMergeAreaEntered(Area2D area)
    {
        // 防止重复合并
        if (_isMerging) return;

        // 检查是否是其他 SourceBlockGroup 的 MergeArea
        if (area.GetParent() is SourceBlockGroup otherGroup && otherGroup != this && !otherGroup._isMerging)
        {
            // 执行合并
            MergeWith(otherGroup);
        }
    }

    /// <summary>
    /// 与另一个 SourceBlockGroup 合并
    /// </summary>
    /// <param name="otherGroup">要合并的组</param>
    private void MergeWith(SourceBlockGroup otherGroup)
    {
        // 设置合并状态，防止重复合并
        _isMerging = true;
        otherGroup._isMerging = true;

        GD.Print($"开始合并 SourceBlockGroup：当前组 {sourceBlocks.Count} 个方块 + 其他组 {otherGroup.sourceBlocks.Count} 个方块");

        // 停止所有相关的下落动画
        StopGroupFalling();
        otherGroup.StopGroupFalling();

        // 停止所有单个方块的下落动画
        foreach (var block in sourceBlocks)
        {
            block.StopMoving(); // 停止方块的移动状态
        }
        foreach (var block in otherGroup.sourceBlocks)
        {
            block.StopMoving(); // 停止方块的移动状态
        }

        // 获取另一个组的所有方块
        var otherBlocks = otherGroup.GetSourceBlocks().ToList();

        // 将另一个组的所有方块添加到当前组
        foreach (var block in otherBlocks)
        {
            // 从原组移除（会自动清除 ParentGroup 引用）
            otherGroup.RemoveSourceBlock(block);
            // 添加到当前组（会自动设置 ParentGroup 引用）
            AddSourceBlock(block);
        }

        // 断开被合并组的信号连接，避免重复合并
        if (otherGroup._mergeArea != null)
        {
            otherGroup._mergeArea.AreaEntered -= otherGroup.OnMergeAreaEntered;
        }

        // 更新合并区域
        UpdateMergeArea();

        // 销毁被合并的组
        otherGroup.QueueFree();

        // 重置合并状态
        _isMerging = false;

        GD.Print($"SourceBlockGroup 合并完成！当前组包含 {sourceBlocks.Count} 个方块，将作为整体下落");
    }

    /// <summary>
    /// 更新合并检测区域，覆盖所有方块
    /// </summary>
    private void UpdateMergeArea()
    {
        if (sourceBlocks.Count == 0)
        {
            _mergeShape.Size = Vector2.Zero;
            return;
        }

        // 计算所有方块的边界
        Vector2 minPos = new Vector2(Mathf.Inf, Mathf.Inf);
        Vector2 maxPos = new Vector2(-Mathf.Inf, -Mathf.Inf);

        foreach (var block in sourceBlocks)
        {
            Vector2 blockPos = block.GlobalPosition;
            Vector2 cellSize = GridConfig.Instance.CellSize;

            minPos.X = Mathf.Min(minPos.X, blockPos.X - cellSize.X / 2);
            minPos.Y = Mathf.Min(minPos.Y, blockPos.Y - cellSize.Y / 2);
            maxPos.X = Mathf.Max(maxPos.X, blockPos.X + cellSize.X / 2);
            maxPos.Y = Mathf.Max(maxPos.Y, blockPos.Y + cellSize.Y / 2);
        }

        // 设置碰撞区域的大小和位置
        Vector2 size = maxPos - minPos;
        Vector2 center = (minPos + maxPos) / 2;

        _mergeShape.Size = size;
        _mergeArea.GlobalPosition = center;
    }

    public override void _Process(double delta)
    {
        if (!IsOnFloor() && !IsMoving() && !_isMerging)
        {
            // 整个组作为一个整体下落
            _ = FallAsGroupAsync();
        }
    }

    public void AddSourceBlock(SourceBlock sourceBlock)
    {
        sourceBlocks.Add(sourceBlock);
        sourceBlock.ParentGroup = this; // 设置父组引用
        UpdateMergeArea(); // 更新合并区域
    }

    public void RemoveSourceBlock(SourceBlock sourceBlock)
    {
        sourceBlocks.Remove(sourceBlock);
        sourceBlock.ParentGroup = null; // 清除父组引用
        UpdateMergeArea(); // 更新合并区域

        // 如果组变空了，销毁自己
        if (sourceBlocks.Count == 0)
        {
            StopGroupFalling(); // 停止组的下落动画
            QueueFree();
        }
    }

    public bool ContainsSourceBlock(SourceBlock sourceBlock)
    {
        return sourceBlocks.Contains(sourceBlock);
    }

    public HashSet<SourceBlock> GetSourceBlocks()
    {
        return sourceBlocks;
    }

    public int Count => sourceBlocks.Count;

    public bool IsEmpty => sourceBlocks.Count == 0;

    public bool IsMoving()
    {
        // 检查是否有任何方块在移动，或者组本身在下落
        if (_isGroupFalling) return true;

        foreach (var block in sourceBlocks)
        {
            if (block.IsMoving())
            {
                return true;
            }
        }
        return false;
    }

    public bool IsOnFloor()
    {
        foreach (var block in sourceBlocks)
        {
            if (block.IsOnFloor())
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// 整个组作为一个整体下落
    /// </summary>
    public async System.Threading.Tasks.Task FallAsGroupAsync()
    {
        if (_isGroupFalling || sourceBlocks.Count == 0) return;

        _isGroupFalling = true;

        // 停止之前的下落动画
        _groupFallTween?.Kill();

        // 创建新的 Tween
        _groupFallTween = CreateTween();

        // 计算下落距离
        Vector2 fallDistance = new Vector2(0, GridConfig.Instance.CellSize.Y);

        // 同时移动所有方块
        foreach (var block in sourceBlocks)
        {
            Vector2 targetPosition = block.Position + fallDistance;
            _groupFallTween.Parallel().TweenProperty(block, "position", targetPosition, 1.0f / 5.0f)
                .SetTrans(Tween.TransitionType.Sine);
        }

        // 等待动画完成
        await ToSignal(_groupFallTween, "finished");

        // 更新所有方块的网格位置
        foreach (var block in sourceBlocks)
        {
            block.GridPosition += Vector2I.Down;
        }

        // 更新合并区域
        UpdateMergeArea();

        _isGroupFalling = false;
    }

    /// <summary>
    /// 停止组的下落动画
    /// </summary>
    public void StopGroupFalling()
    {
        _groupFallTween?.Kill();
        _isGroupFalling = false;
    }

    /// <summary>
    /// 清理资源
    /// </summary>
    public override void _ExitTree()
    {
        // 停止所有动画
        StopGroupFalling();

        // 断开信号连接
        if (_mergeArea != null)
        {
            _mergeArea.AreaEntered -= OnMergeAreaEntered;
        }

        // 清理所有方块的父组引用
        foreach (var block in sourceBlocks)
        {
            if (block != null)
            {
                block.ParentGroup = null;
            }
        }

        base._ExitTree();
    }

    /// <summary>
    /// 获取组的边界框
    /// </summary>
    /// <returns>边界框</returns>
    public Rect2 GetBounds()
    {
        if (sourceBlocks.Count == 0)
            return new Rect2();

        Vector2 minPos = new Vector2(Mathf.Inf, Mathf.Inf);
        Vector2 maxPos = new Vector2(-Mathf.Inf, -Mathf.Inf);

        foreach (var block in sourceBlocks)
        {
            Vector2 blockPos = block.GlobalPosition;
            Vector2 cellSize = GridConfig.Instance.CellSize;

            minPos.X = Mathf.Min(minPos.X, blockPos.X - cellSize.X / 2);
            minPos.Y = Mathf.Min(minPos.Y, blockPos.Y - cellSize.Y / 2);
            maxPos.X = Mathf.Max(maxPos.X, blockPos.X + cellSize.X / 2);
            maxPos.Y = Mathf.Max(maxPos.Y, blockPos.Y + cellSize.Y / 2);
        }

        return new Rect2(minPos, maxPos - minPos);
    }

    /// <summary>
    /// 获取组的中心位置
    /// </summary>
    /// <returns>中心位置</returns>
    public Vector2 GetCenterPosition()
    {
        if (sourceBlocks.Count == 0)
            return Vector2.Zero;

        Vector2 sum = Vector2.Zero;
        foreach (var block in sourceBlocks)
        {
            sum += block.GlobalPosition;
        }
        return sum / sourceBlocks.Count;
    }

    /// <summary>
    /// 检查是否与另一个组重叠
    /// </summary>
    /// <param name="otherGroup">另一个组</param>
    /// <returns>是否重叠</returns>
    public bool OverlapsWith(SourceBlockGroup otherGroup)
    {
        return GetBounds().Intersects(otherGroup.GetBounds());
    }

}