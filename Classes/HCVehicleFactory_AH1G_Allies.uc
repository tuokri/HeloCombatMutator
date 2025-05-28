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
class HCVehicleFactory_AH1G_Allies extends ROVehicleFactory_AH1G;

simulated function PostBeginPlay()
{
    local ROGameInfo ROGI;

    super(ROTransportVehicleFactory).PostBeginPlay();

    ROGI = ROGameInfo(WorldInfo.Game);
    if( ROGI != none && ROGI.bCampaignGame )
    {
        if( WorldInfo.NetMode != NM_Standalone )
            VehicleClass = (ROGI.CurrentSouthernFaction == SFOR_AusArmy) ? CampaignAusVehicleClass : CampaignNonAusVehicleClass;

        if( ROGI.CampaignWarPhase == ROCWP_Early )
            bDisableForCampaign = true;
        else
            bDisableForCampaign = false;
    }
    else
        bDisableForCampaign = false;
}

DefaultProperties
{
    VehicleClass=class'HCHeli_AH1G_Allies_Content'
    EnemyVehicleClass=class'HCHeli_AH1G_Content'
    // For campaign
    CampaignNonAusVehicleClass=class'HCHeli_AH1G_Content'
    CampaignAusVehicleClass=class'HCHeli_UH1H_Gunship_Content'
}
