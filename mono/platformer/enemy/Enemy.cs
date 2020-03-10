using Godot;
using System;

public class Enemy : RigidBody2D
{
    private const int WalkSpeed = 50;
    private const int StateWalking = 0;
    private const int StateDying = 1;
    private const float AngularVelocityConstant = 33.0f;
    private const float FrictionConstant = 1.0f;
    private const float WallSide = 1.0f;
    private const float CollisionNormalXComponent = 1.0f;

    private int _state;
    private int _direction;
    private String _animation;
    private RayCast2D _rayCastLeft;
    private RayCast2D _rayCastRight;
    private Bullet _bullet;

    public override void _Ready()
    {
        _state = StateWalking;
        _direction = -1;
        _animation = "";
        _rayCastLeft = GetNode("RaycastLeft") as RayCast2D;
        _rayCastRight = GetNode("RaycastRight") as RayCast2D;
    }

    public void Die()
    {
        QueueFree();
    }

    public void PreExplode()
    {
        GetNode("Shape1").QueueFree();
        GetNode("Shape2").QueueFree();
        GetNode("Shape3").QueueFree();

        Mode = ModeEnum.Static;
        AudioStreamPlayer2D soundExplode = GetNode("SoundExplode") as AudioStreamPlayer2D;
        soundExplode.Play();
    }

    public override void _IntegrateForces(Physics2DDirectBodyState bodyState)
    {
        String correctAnimation = FindCorrectAnimation();

        if (correctAnimation.Equals("walk"))
        {
            Walk(bodyState);
        }

        if (_animation != correctAnimation)
        {
            UpdateAnimation(correctAnimation);
        }

        UpdateLinearVelocity(bodyState);
    }

    private void Walk(Physics2DDirectBodyState bodyState)
    {

        float wallSide = 0.0f;
        for (int i = 0; i < bodyState.GetContactCount(); i++)
        {
            Godot.Object contactColliderObject = bodyState.GetContactColliderObject(i);
            Vector2 contactLocalNormal = bodyState.GetContactLocalNormal(i);

            if (contactColliderObject != null && contactColliderObject is Bullet)
            {
                Bullet contactCollidedBullet = contactColliderObject as Bullet;
                if (!contactCollidedBullet.Disabled)
                {
                    CallDeferred("BulletCollider", contactCollidedBullet, bodyState, contactLocalNormal);
                    break;
                }
            }

            wallSide = FindCorrectWallSide(contactLocalNormal, wallSide);
        }

        int correctDirection = FindCorrectDirection(wallSide);
        if (_direction != correctDirection)
        {
            _direction = correctDirection;

            Sprite sprite = GetNode("Sprite") as Sprite;
            Vector2 scale = sprite.Scale;
            scale.x = -_direction;
            sprite.Scale = scale;
        }
    }

    private void UpdateAnimation(String newAnimation)
    {
        _animation = newAnimation;
        AnimationPlayer animationPlayer = GetNode("Anim") as AnimationPlayer;
        animationPlayer.Play(_animation);
    }

    private void UpdateLinearVelocity(Physics2DDirectBodyState bodyState)
    {
        Vector2 linearVelocity = LinearVelocity;
        linearVelocity.x = _direction * WalkSpeed;
        bodyState.LinearVelocity = linearVelocity;
    }

    private String FindCorrectAnimation()
    {
        if (_state == StateDying)
        {
            return "explode";
        }
        else if (_state == StateWalking)
        {
            return "walk";
        }

        return _animation;
    }

    private float FindCorrectWallSide(Vector2 contactLocalNormal, float wallSide)
    {
        // Subtract 0.1f for correct float comparison
        if (contactLocalNormal.x > CollisionNormalXComponent - 0.1f)
        {
            return WallSide;
        }
        else if (contactLocalNormal.x < -CollisionNormalXComponent + 0.1f)
        {
            return -WallSide;
        }

        return wallSide;
    }

    private int FindCorrectDirection(float wallSide)
    {
        if (wallSide != 0 && wallSide != _direction)
        {
            return -_direction;
        }

        if (_direction < 0 && !_rayCastLeft.IsColliding() && _rayCastRight.IsColliding())
        {
            return -_direction;
        }
        else if (_direction > 0 && !_rayCastRight.IsColliding() && _rayCastLeft.IsColliding())
        {
            return -_direction;
        }

        return _direction;
    }


    private void BulletCollider(Bullet contactCollidedBullet, Physics2DDirectBodyState bodyState, Vector2 contactLocalNormal)
    {
        Mode = ModeEnum.Rigid;
        _state = StateDying;

        bodyState.AngularVelocity = Mathf.Sign(contactLocalNormal.x) * AngularVelocityConstant;
        Friction = FrictionConstant;
        contactCollidedBullet.Disable();

        AudioStreamPlayer2D soundHit = GetNode("SoundHit") as AudioStreamPlayer2D;
        soundHit.Play();
    }
}
