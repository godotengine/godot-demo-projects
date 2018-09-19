using Godot;

class Bullet : RigidBody2D
{
    void _OnBulletBodyEnter(PhysicsBody2D body)
    {
        if (body is IShootable shootable)
        {
            shootable.HitByBullet();
        }
    }

    void _OnTimerTimeout()
    {
        GetNode<AnimationPlayer>("anim").Play("shutdown");
    }
}
