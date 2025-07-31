using Godot;
using System;

public partial class SourceBlock : Block
{
    [Signal]
    public delegate void BeingEatenEventHandler(SourceBlock sourceBlock);

    public SourceBlockGroup ParentGroup { get; set; }

    public SourceBlock(Vector2I gridPosition) : base(gridPosition)
    {
        CollisionLayer = CollisionLayers.PICKUP;
    }

    protected override void SetupTileBackground()
    {
        // 使用金色瓦片作为背景
        var texture = TileConfig.LoadTileTexture();
        var region = TileConfig.Tiles.SourceBlock;

        SetupBackgroundSprite(texture, region);
    }

    public void StartBeingEaten()
    {
        EmitSignal(SignalName.BeingEaten, this);
        PlayEatenAnimation();
    }

    private void PlayEatenAnimation()
    {
        // 创建缩放和淡出动画
        var tween = CreateTween();

        // 并行执行多个动画
        tween.Parallel().TweenProperty(this, "scale", Vector2.Zero, 0.5f)
            .SetTrans(Tween.TransitionType.Back)
            .SetEase(Tween.EaseType.In);

        tween.Parallel().TweenProperty(this, "modulate:a", 0.0f, 0.5f)
            .SetTrans(Tween.TransitionType.Sine)
            .SetEase(Tween.EaseType.Out);

        // 动画完成后移除节点
        tween.TweenCallback(Callable.From(() => QueueFree()));
    }

}