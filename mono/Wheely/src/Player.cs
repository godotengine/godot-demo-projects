using Godot;
using System;

public class Player : KinematicBody2D{
    public Vector2 velocity = new Vector2(0,0);
    public Sprite sprite;
    private float forwardAccell = 0f;
    //The below 2 vars auto update, & can be used to calculate all info about "forward"
    // See `this.calculateForwardAngle()` for more information
    private Vector2 currentTravel = new Vector2(0,0);
    private Vector2 currentNormal = new Vector2(0,-1);
    private const float GRAVITY  = 600.0f;
    private const float MAX_GRAVITY_SPEED = 300f;
    private const float MAX_FORWARD_ACCEL = 40f;
    private const float MAX_BACKWARD_ACCEL = - MAX_FORWARD_ACCEL;
    private const float MAX_SPEED = 300f;
    private const float FORWARD_ACCEL_UNIT = 1.5f;
    private const float DECELL_EFFECT = 0.9f;
    private const float FRICTION_EFFECT = 0.9f;

    public override void _Ready(){
        for(int i = 0; i<this.GetChildCount(); i++){
            var child = this.GetChild(i);
            if(child is Sprite){
                this.sprite = (Sprite)child;
                return;
            }
        }
        throw new Exception("No Sprite found as Child of Player");
    }

    public override void _PhysicsProcess(float delta){
        this.reactToInput(delta);
        this.processPhysics(delta);
        this.applyPhysics(delta);
        this.updateSprite(delta);
    }

    private void reactToInput(float delta){
        if (Input.IsActionPressed("ui_left") &&
        (this.forwardAccell >= MAX_BACKWARD_ACCEL)){
            this.forwardAccell -= FORWARD_ACCEL_UNIT;
        }
        else if (Input.IsActionPressed("ui_right") &&
        (this.forwardAccell <= MAX_FORWARD_ACCEL)) {       
            this.forwardAccell += FORWARD_ACCEL_UNIT;
        }
        else{
            this.forwardAccell *= DECELL_EFFECT;
        }
    }

    private void processPhysics(float delta){
        //Process Gravity
        if(this.velocity.y <= MAX_GRAVITY_SPEED){        
            this.velocity.y += delta * GRAVITY;
        }

        //Process Collision with platforms
        var numCollisions = this.GetSlideCount();
        for(int i = 0; i < this.GetSlideCount(); i++){
           var collision = this.GetSlideCollision(i);
           //Save relevant collision info to this
           this.currentTravel = collision.Travel;
           this.currentNormal = collision.Normal;
           //Calculate the Forward movement
           var forwardAngle = this.calculateForwardAngle();
           if (Math.Abs(this.velocity.Length()) <= MAX_SPEED){
                this.velocity.x += forwardAngle.x*forwardAccell;
                this.velocity.y += forwardAngle.y*forwardAccell;
            }
            //Apply the friction effect
            this.velocity *= FRICTION_EFFECT;
            break; //For now, only process 1 collision (buggy with multiple atm)
        }
    }

    /// "Normal" is defined as the direction "up" away from the platform.
    ///     - this is calculated automatically for us for each kinematic collision
    /// "Forward" is defined as the direction to continue following the curve of the platform
    ///     - We must calculate this
    /// Purely mathematically, Forward = Normal + (PI / 2 radians)
    /// In this Godot project, this works for Convex curves, but fails for Concave curves
    ///     - The Player will follow the curve when it should "fly away" from it
    /// The solution to this is to make the angle a bit "above" the traditional "forward".
    ///     - "above" is defined as the direction towards "Normal" (away from the platform)
    ///     - "above" is dependant the direction player is moving (AKA the angle of velocity)
    private Vector2 calculateForwardAngle(){
        //Calculate the angle above foreward
        const float angleAbovePercent = 0.20f;
        var normalAngle = this.currentNormal.Normalized();
        var currentVelocityAngle = this.currentTravel.Normalized();
        var angleAbove = angleAbovePercent * currentVelocityAngle.AngleTo(normalAngle);
        //Apply the previously calculate "angleAbove" to the forward angle 
        var unadjustedForwardAngle = normalAngle.Rotated((float)Math.PI / 2f).Normalized();
        var adjustedForwardAngle = unadjustedForwardAngle.Rotated(angleAbove);
        return adjustedForwardAngle;
    }
    private void applyPhysics(float delta){
        MoveAndSlide(linearVelocity: this.velocity);
    }

    private void updateSprite(float delta){
        const float arbitraryConstant = 400;
        this.sprite.Rotate(this.forwardAccell / arbitraryConstant);
    }
}