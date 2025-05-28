/*
 * Copyright (c) 2021-2025 Tuomo Kriikkula <tuokri@tuta.io>
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
class HCVehicleFactory_OH6_Allies extends ROVehicleFactory_OH6;

simulated function PostBeginPlay()
{
    local ROGameInfo ROGI;

    super(ROTransportVehicleFactory).PostBeginPlay();

    ROGI = ROGameInfo(WorldInfo.Game);

    if(ROGI != none && ROGI.bCampaignGame)
    {
        if(ROGI.CampaignWarPhase == ROCWP_Early)
        {
            bDisableForCampaign = true;
            return;
        }
        else
            bDisableForCampaign = false;
    }

    if( ROMapInfo(WorldInfo.GetMapInfo()) != none && ROMapInfo(WorldInfo.GetMapInfo()).SouthernForce == SFOR_AusArmy )
        VehicleClass = AusLoachClass;
    else
        VehicleClass = USLoachClass;
}

DefaultProperties
{
    USLoachClass=class'HCHeli_OH6_Allies_Content'
    AusLoachClass=class'HCHeli_OH6_Allies_Content'
    EnemyVehicleClass=class'HCHeli_OH6_Content'
    DrawScale=1.0

    bTransportHeloFactory=true
}
