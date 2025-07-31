using Godot;
using System;
using System.Threading.Tasks;

public abstract partial class Block : StaticBody2D
{

    public Vector2I GridPosition { get; set; }

    protected Sprite2D _backgroundSprite;
    protected CollisionShape2D _collisionShape;
    protected RectangleShape2D _rectangleShape;
    protected RayCast2D _gravityRayCast;
    protected Tween _fallTween; // 下落动画

    protected bool Moving = false;

    [Export]
    public float AnimationSpeed = 5f;

    public Block(Vector2I gridPosition)
    {
        GridPosition = gridPosition;
        Vector2 worldPosition = GridConfig.Instance.GridToWorld(gridPosition);
        Position = worldPosition;

        CollisionLayer = CollisionLayers.WALLS;
        CollisionMask = 0u;

        SetupTileBackground();
        SetupCollision();
        SetupGravityRayCast();
    }

    private void SetupCollision()
    {
        // 创建碰撞形状
        _rectangleShape = new RectangleShape2D();
        _rectangleShape.Size = GridConfig.Instance.CellSize;

        // 创建碰撞组件
        _collisionShape = new CollisionShape2D();
        _collisionShape.Shape = _rectangleShape;
        _collisionShape.Position = GridConfig.Instance.CellSize / 2;

        // 添加到节点树
        AddChild(_collisionShape);
    }

    public void SetupGravityRayCast()
    {
        _gravityRayCast = new RayCast2D();
        _gravityRayCast.Position = Vector2.Zero;
        _gravityRayCast.TargetPosition = new Vector2(0, GridConfig.Instance.CellSize.Y);

        _gravityRayCast.CollisionMask = CollisionLayers.GROUND | CollisionLayers.PLAYER;

        AddChild(_gravityRayCast);
    }

    protected abstract void SetupTileBackground();

    protected void SetupBackgroundSprite(Texture2D texture, Rect2 region)
    {
        // 创建 Sprite2D 作为背景
        _backgroundSprite = new Sprite2D();

        // 设置纹理和区域
        _backgroundSprite.Texture = texture;
        _backgroundSprite.RegionEnabled = true;
        _backgroundSprite.RegionRect = region;

        // 设置位置和缩放
        _backgroundSprite.Position = GridConfig.Instance.CellSize / 2;
        _backgroundSprite.Scale = GridConfig.Instance.CellSize / region.Size;

        AddChild(_backgroundSprite);
    }

    public bool IsMoving()
    {
        return Moving;
    }

    /// <summary>
    /// 停止方块的移动
    /// </summary>
    public void StopMoving()
    {
        // 停止任何正在进行的下落动画
        _fallTween?.Kill();
        Moving = false;
    }

    public virtual async Task FallAsync()
    {
        Vector2 targetPosition = Position + new Vector2(0, GridConfig.Instance.CellSize.Y);
        GridPosition += Vector2I.Down;

        Moving = true;

        // 停止之前的动画
        _fallTween?.Kill();

        // 创建新的动画
        _fallTween = CreateTween();
        _fallTween.TweenProperty(this, "position", targetPosition, 1.0 / AnimationSpeed).SetTrans(Tween.TransitionType.Sine);
        await ToSignal(_fallTween, "finished");

        Moving = false;
    }

    public virtual bool IsOnFloor()
    {
        _gravityRayCast.Position = Vector2.Zero;
        _gravityRayCast.TargetPosition = new Vector2(0, GridConfig.Instance.CellSize.Y);
        _gravityRayCast.ForceRaycastUpdate();
        return _gravityRayCast.IsColliding();
    }
}