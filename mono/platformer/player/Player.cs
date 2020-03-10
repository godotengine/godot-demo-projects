using Godot;
using System;

public class Player : RigidBody2D
{
    private const float WalkAcceleration = 800.0f;
    private const float WalkDeacceleration = 800.0f;
    private const float WalkMaxVelocity = 200.0f;
    private const float AirAcceleration = 200.0f;
    private const float AirDeacceleration = 200.0f;
    private const float JumpVelocity = 460.0f;
    private const float StopJumpForce = 900.0f;
    private const float MaxShootPoseTime = 0.3f;
    private const float MaxFloorAirborneTime = 0.15f;

    private bool _sidingLeft;
    private bool _jumping;
    private bool _stoppingJump;
    private bool _shooting;
    private float _floorHVelocity;
    private float _airborneTime;
    private float _shootTime;
    private String _animation;
    private PackedScene _bulletScene;
    private PackedScene _enemyScene;

    public override void _Ready()
    {
        _animation = "";
        _sidingLeft = false;
        _jumping = false;
        _stoppingJump = false;
        _shooting = false;
        _floorHVelocity = 0.0f;
        _airborneTime = Mathf.Pow(10, 20);
        _shootTime = Mathf.Pow(10, 20);
        _bulletScene = ResourceLoader.Load("res://player/Bullet.tscn") as PackedScene;
        _enemyScene = ResourceLoader.Load("res://enemy/Enemy.tscn") as PackedScene;
    }

    public void ShotBullet()
    {
        _shootTime = 0.0f;
        RigidBody2D bullet = _bulletScene.Instance() as RigidBody2D;
        float side = _sidingLeft ? -1.0f : 1.0f;
        Position2D bulletShoot = GetNode("BulletShoot") as Position2D;
        Vector2 bulletPosition = Position + bulletShoot.Position * (new Vector2(side, 1.0f));

        bullet.Position = bulletPosition;
        GetParent().AddChild(bullet);

        bullet.LinearVelocity = new Vector2(800.0f * side, -80.0f);

        Particles2D particles = GetNode("Sprite/Smoke") as Particles2D;
        particles.Restart();
        AudioStreamPlayer2D soundShoot = GetNode("SoundShoot") as AudioStreamPlayer2D;
        soundShoot.Play();

        AddCollisionExceptionWith(bullet);
    }

    public override void _IntegrateForces(Physics2DDirectBodyState bodyState)
    {
        Vector2 linearVelocity = bodyState.LinearVelocity;
        float step = bodyState.Step;

        PlayerInputInteraction playerInputInteraction = ListenToPlayerInput();

        linearVelocity.x -= _floorHVelocity;
        _floorHVelocity = 0.0f;

        FloorContact floorContact = FindFloorContact(bodyState);

        ProcessSpawn(playerInputInteraction);
        ProcessShooting(playerInputInteraction, step);
        ProcessFloorContact(floorContact, step);
        linearVelocity = ProcessJump(playerInputInteraction, linearVelocity, step);
        linearVelocity = ProcessPlayerMovement(playerInputInteraction, linearVelocity, step);

        _shooting = playerInputInteraction.Shoot;
        if (floorContact.FoundFloor)
        {
            _floorHVelocity = bodyState.GetContactColliderVelocityAtPosition(floorContact.FloorIndex).x;
            linearVelocity.x += _floorHVelocity;
        }

        linearVelocity += bodyState.TotalGravity * step;
        bodyState.LinearVelocity = linearVelocity;
    }

    private PlayerInputInteraction ListenToPlayerInput()
    {
        bool moveLeft = Input.IsActionPressed("move_left");
        bool moveRight = Input.IsActionPressed("move_right");
        bool jump = Input.IsActionPressed("jump");
        bool shoot = Input.IsActionPressed("shoot");
        bool spawn = Input.IsActionPressed("spawn");

        return new PlayerInputInteraction(moveLeft, moveRight, jump, shoot, spawn);
    }

    private void ProcessSpawn(PlayerInputInteraction playerInputInteraction)
    {
        if (playerInputInteraction.Spawn)
        {
            RigidBody2D enemy = _enemyScene.Instance() as RigidBody2D;
            Vector2 position = Position;

            position.y = position.y - 100;
            enemy.Position = position;

            GetParent().AddChild(enemy);
        }
    }

    private void ProcessShooting(PlayerInputInteraction playerInputInteraction, float step)
    {
        if (playerInputInteraction.Shoot && !_shooting)
        {
            CallDeferred("ShotBullet");
        }
        else
        {
            _shootTime += step;
        }
    }

    private void ProcessFloorContact(FloorContact floorContact, float step)
    {
        if (floorContact.FoundFloor)
        {
            _airborneTime = 0.0f;
        }
        else
        {
            _airborneTime += step;
        }
    }

    private Vector2 ProcessJump(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity, float step)
    {
        if (!_jumping)
        {
            return linearVelocity;
        }

        if (linearVelocity.y > 0)
        {
            _jumping = false;
        }
        else if (!playerInputInteraction.Jump)
        {
            _stoppingJump = true;
        }

        if (_stoppingJump)
        {
            linearVelocity.y += StopJumpForce * step;
        }

        return linearVelocity;
    }

    private Vector2 ProcessPlayerMovement(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity, float step)
    {

        bool onFloor = _airborneTime < MaxFloorAirborneTime;

        if (onFloor)
        {
            linearVelocity = ProcessPlayerDirectionalMovement(playerInputInteraction, linearVelocity, step);
            linearVelocity = ProcessJumpMovement(playerInputInteraction, linearVelocity, step);
            ProcessPlayerSiding(playerInputInteraction, linearVelocity);
            ProcessAnimation(playerInputInteraction, linearVelocity);
        }
        else
        {
            linearVelocity = ProcessPlayerInAirDirectionalMovement(playerInputInteraction, linearVelocity, step);
            ProcessInAirAnimation(playerInputInteraction, linearVelocity);
        }

        return linearVelocity;
    }

    private FloorContact FindFloorContact(Physics2DDirectBodyState bodyState)
    {
        FloorContact floorContact = new FloorContact(false, -1);

        for (int i = 0; i < bodyState.GetContactCount(); i++)
        {
            Vector2 contactLocalNormal = bodyState.GetContactLocalNormal(i);

            if (contactLocalNormal.Dot(new Vector2(0, -1)) > 0.6f)
            {
                floorContact.FoundFloor = true;
                floorContact.FloorIndex = i;
            }
        }

        return floorContact;
    }

    private Vector2 ProcessPlayerDirectionalMovement(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity, float step)
    {
        if (playerInputInteraction.MoveLeft && !playerInputInteraction.MoveRight)
        {
            if (linearVelocity.x > -WalkMaxVelocity)
            {
                linearVelocity.x -= WalkAcceleration * step;
            }
        }
        else if (playerInputInteraction.MoveRight && !playerInputInteraction.MoveLeft)
        {
            if (linearVelocity.x < WalkMaxVelocity)
            {
                linearVelocity.x += WalkAcceleration * step;
            }
        }
        else
        {
            float linearVelocityX = Mathf.Abs(linearVelocity.x);
            linearVelocityX -= WalkDeacceleration * step;
            linearVelocityX = linearVelocityX < 0 ? 0 : linearVelocityX;
            linearVelocity.x = Mathf.Sign(linearVelocity.x) * linearVelocityX;
        }

        return linearVelocity;
    }

    private Vector2 ProcessPlayerInAirDirectionalMovement(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity, float step)
    {
        if (playerInputInteraction.MoveLeft && !playerInputInteraction.MoveRight)
        {
            if (linearVelocity.x > -WalkMaxVelocity)
            {
                linearVelocity.x -= AirAcceleration * step;
            }
        }
        else if (playerInputInteraction.MoveRight && !playerInputInteraction.MoveLeft)
        {
            if (linearVelocity.x < WalkMaxVelocity)
            {
                linearVelocity.x += AirAcceleration * step;
            }
        }
        else
        {
            float linearVelocityX = Mathf.Abs(linearVelocity.x);
            linearVelocityX -= AirDeacceleration * step;
            linearVelocityX = linearVelocityX < 0 ? 0 : linearVelocityX;
            linearVelocity.x = Mathf.Sign(linearVelocity.x) * linearVelocityX;
        }

        return linearVelocity;
    }

    private Vector2 ProcessJumpMovement(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity, float step)
    {
        if (!_jumping && playerInputInteraction.Jump)
        {
            linearVelocity.y = -JumpVelocity;
            _jumping = true;
            _stoppingJump = false;
            AudioStreamPlayer2D soundJump = GetNode("SoundJump") as AudioStreamPlayer2D;
            soundJump.Play();
        }

        return linearVelocity;
    }

    private void ProcessPlayerSiding(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity)
    {

        bool newSidingLeft = _sidingLeft;
        if (linearVelocity.x < 0 && playerInputInteraction.MoveLeft)
        {
            newSidingLeft = true;
        }
        else if (linearVelocity.x > 0 && playerInputInteraction.MoveRight)
        {
            newSidingLeft = false;
        }

        UpdateSidingLeft(newSidingLeft);
    }

    private void ProcessAnimation(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity)
    {
        String newAnimation = _animation;
        if (_jumping)
        {
            newAnimation = "jumping";
        }
        else if (Mathf.Abs(linearVelocity.x) < 0.1)
        {
            if (_shootTime < MaxShootPoseTime)
            {
                newAnimation = "idle_weapon";
            }
            else
            {
                newAnimation = "idle";
            }
        }
        else
        {
            if (_shootTime < MaxShootPoseTime)
            {
                newAnimation = "run_weapon";
            }
            else
            {
                newAnimation = "run";
            }
        }

        UpdateAnimation(newAnimation);
    }

    private void ProcessInAirAnimation(PlayerInputInteraction playerInputInteraction, Vector2 linearVelocity)
    {
        String newAnimation = _animation;
        if (linearVelocity.y < 0)
        {
            if (_shootTime < MaxShootPoseTime)
            {
                newAnimation = "jumping_weapon";
            }
            else
            {
                newAnimation = "jumping";
            }
        }
        else
        {
            if (_shootTime < MaxShootPoseTime)
            {
                newAnimation = "falling_weapon";
            }
            else
            {
                newAnimation = "falling_weapon";
            }
        }

        UpdateAnimation(newAnimation);
    }

    private void UpdateSidingLeft(bool newSidingLeft)
    {
        Sprite sprite = GetNode("Sprite") as Sprite;
        Vector2 scale = sprite.Scale;
        if (!newSidingLeft.Equals(_sidingLeft))
        {
            if (newSidingLeft)
            {
                scale.x = -1;
            }
            else
            {
                scale.x = 1;
            }

        }

        sprite.Scale = scale;
        _sidingLeft = newSidingLeft;
    }

    private void UpdateAnimation(String newAnimation)
    {
        if (!newAnimation.Equals(_animation))
        {
            _animation = newAnimation;
            AnimationPlayer animationPlayer = GetNode("Anim") as AnimationPlayer;
            animationPlayer.Play(_animation);
        }
    }
}
