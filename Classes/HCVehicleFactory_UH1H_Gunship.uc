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
class HCVehicleFactory_UH1H_Gunship extends HCVehicleFactory_AH1G;

DefaultProperties
{
    Begin Object Name=SVehicleMesh
        SkeletalMesh=SkeletalMesh'VH_VN_AUS_Bushranger.Mesh.AUS_Bushranger_Rig_Master'
        Materials[0]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_M_Bushranger'
        Materials[4]=MaterialInstanceConstant'HC_VH_TintedHelicopters.Materials.HC_M_Bushranger_Armament'
        Translation=(X=0.0,Y=0.0,Z=0.0)
    End Object

    DrawScale=1.0

    VehicleClass=class'HCHeli_UH1H_Gunship_Content'
    EnemyVehicleClass=class'HCHeli_UH1H_Gunship_Allies_Content'
}
