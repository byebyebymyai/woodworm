using Godot;
using System.Collections.Generic;

/// <summary>
/// SourceBlockGroup 管理器
/// 用于创建和管理 SourceBlockGroup 实例
/// </summary>
public partial class SourceBlockGroupManager : Node
{
    private List<SourceBlockGroup> groups = new List<SourceBlockGroup>();

    /// <summary>
    /// 创建一个新的 SourceBlockGroup
    /// </summary>
    /// <param name="sourceBlocks">要加入组的 SourceBlock 列表</param>
    /// <returns>创建的 SourceBlockGroup</returns>
    public SourceBlockGroup CreateGroup(List<SourceBlock> sourceBlocks)
    {
        var group = new SourceBlockGroup();

        // 将组添加到场景树
        GetTree().CurrentScene.AddChild(group);

        // 添加所有 SourceBlock 到组中
        foreach (var block in sourceBlocks)
        {
            group.AddSourceBlock(block);
        }

        // 将组添加到管理列表
        groups.Add(group);

        // 连接组的销毁信号，以便从列表中移除
        group.TreeExiting += () => groups.Remove(group);

        GD.Print($"创建了新的 SourceBlockGroup，包含 {sourceBlocks.Count} 个方块");

        return group;
    }

    /// <summary>
    /// 创建一个包含单个方块的组
    /// </summary>
    /// <param name="sourceBlock">要加入组的 SourceBlock</param>
    /// <returns>创建的 SourceBlockGroup</returns>
    public SourceBlockGroup CreateSingleBlockGroup(SourceBlock sourceBlock)
    {
        return CreateGroup(new List<SourceBlock> { sourceBlock });
    }

    /// <summary>
    /// 获取所有活跃的组
    /// </summary>
    /// <returns>活跃的组列表</returns>
    public List<SourceBlockGroup> GetActiveGroups()
    {
        return new List<SourceBlockGroup>(groups);
    }

    /// <summary>
    /// 获取活跃组的数量
    /// </summary>
    /// <returns>组数量</returns>
    public int GetGroupCount()
    {
        return groups.Count;
    }

    /// <summary>
    /// 示例：创建测试用的组
    /// </summary>
    public void CreateTestGroups()
    {
        // 创建第一个组 - 2x2 的方块组
        var group1Blocks = new List<SourceBlock>
        {
            new SourceBlock(new Vector2I(0, 0)),
            new SourceBlock(new Vector2I(1, 0)),
            new SourceBlock(new Vector2I(0, 1)),
            new SourceBlock(new Vector2I(1, 1))
        };

        // 将方块添加到场景中
        foreach (var block in group1Blocks)
        {
            GetTree().CurrentScene.AddChild(block);
        }

        CreateGroup(group1Blocks);

        // 创建第二个组 - 单行的方块组
        var group2Blocks = new List<SourceBlock>
        {
            new SourceBlock(new Vector2I(3, 0)),
            new SourceBlock(new Vector2I(4, 0)),
            new SourceBlock(new Vector2I(5, 0))
        };

        // 将方块添加到场景中
        foreach (var block in group2Blocks)
        {
            GetTree().CurrentScene.AddChild(block);
        }

        CreateGroup(group2Blocks);

        GD.Print("创建了测试用的 SourceBlockGroup");
    }
}