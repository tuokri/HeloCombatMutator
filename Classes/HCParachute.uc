/*
 * Copyright (c) 2021-2024 Tuomo Kriikkula <tuokri@tuta.io>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
class HCParachute extends Actor;

// Cross-sectional area of the parachute canopy.
// TODO: what units?
var() float CanopyArea;
// Constant drag coefficient of the parachute.
var() float DragCoeff;
// Mass of the load attached to this parachute. Usually the skydiver.
var() float LoadMass;
// Air density.
var() float AirDensity;

// Magnitude of the drag force applied by this parachute on the attached load.
// TODO: what parameters here?
function float GetDrag(float Speed)
{
    // F = m * g + (1/2) * ρ * v2 * A * Cd
    return LoadMass * PhysicsVolume.GetGravityZ() + 0.5 * AirDensity * (Speed * Speed) * CanopyArea * DragCoeff;
}

DefaultProperties
{
    CanopyArea=100.0
    DragCoeff=1.0
    LoadMass=100.0
    AirDensity=1.0
}
