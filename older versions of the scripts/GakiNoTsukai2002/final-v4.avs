Import("C:\StaxRip\Apps\Plugins\AVS\AnimeIVTC\AnimeIVTC.avsi")
Import("C:\StaxRip\Apps\Plugins\AVS\Deblock_QED\Deblock_QED.avsi")
Import("C:\StaxRip\Apps\Plugins\AVS\DehaloAlpha\Dehalo_alpha.avsi")
Import("C:\StaxRip\Apps\Plugins\AVS\Dither\dither.avsi")
Import("C:\StaxRip\Apps\Plugins\AVS\HQDeringmod\HQDeringmod.avsi")
Import("C:\StaxRip\Apps\Plugins\AVS\QTGMC\QTGMC.avsi")
Import("C:\StaxRip\Apps\Plugins\AVS\SMDegrain\SMDegrain.avsi")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\AddGrainC\AddGrainCMSVC.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\Average\Average.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\Decomb\Decomb.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\Dither\dither.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\EEDI2\EEDI2.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\FFT3DFilter\fft3dfilter.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\JPSDR\Plugins_JPSDR.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\MedianBlur2\MedianBlur2.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\RgTools\RgToolsICC.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\TDeint\TDeintICC.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\masktools2\masktools2.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\modPlus\modPlus.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\mvtools2\mvtools2.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\yadifmod2\yadifmod2.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\Dual\KNLMeansCL\KNLMeansCL.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\Dual\ffms2\ffms2.dll")
LoadPlugin("C:\StaxRip\Apps\Support\DGDecNV\x64 Binaries\DGDecodeNV.dll")

LoadPlugin("C:\Program Files (x86)\Avisynth+\Plugins64\DeDot.dll")
LoadPlugin("C:\Program Files (x86)\Avisynth+\Plugins64\DeCross.dll")

#frame 56145

#WIP convertion para avs neo
DGSource("X:\gaki no tsukai RAW\dvd1\24htag.mkv_t00_temp\24htag.mkv_t00.dgi", deinterlace=0)
#QTGMC(Preset="Draft", ShowSettings=false, Precise=false, TR0=1, TR2=2, Rep0=1, Rep2=1,EdiMode="NNEDI3", ChromaEdi="NNEDI3", NNSize=3, NNeurons=1)

#region De-rainbow

DeCross(ThresholdY=30, Noise=60, Margin=1, Debug=false )


#LUTDeRainbow(cthresh= 20, linkUV=false,mask=true)
Prefetch(1,1)
#endregion

#region KTGMC
OnCPU(2)
#slower stuff consooms way 2 much VRAM
Import("C:\Program Files (x86)\AviSynth+\plugins64+\KTGMC.avsi") 
KTGMC(Preset="Slower", NNSize=3, NNeurons=4, Lossless=0, SourceMatch=0,	\
TR0=2, TR1=2, TR2=2, Rep0=1, Rep1=1, Rep2=1, SubPel=2, PelSearch=2,		\
MatchPreset="Slow", MatchPreset2="Slow", DenoiseMC=true, Denoiser="dfttest")
OnCUDA(2)
Prefetch(1,1)
#endregion

#region XAA
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\SangNom2\SangNom2.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\TEMMod\TEMmod.dll")
Import("C:\Program Files (x86)\AviSynth+\plugins64+\xaaCudaMod.avsi")
xaa(mode="sr 2 nnedi3", chroma=1)
Prefetch(1,1)
#endregion

#region Deblock
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\Deblock\DeblockICC.dll")
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\DCTFilter\DCTFilterICC.dll")
#Deblock_QED(quant1=38, quant2=38, aOff1=6, aOff2=6, bOff1=2, bOff2=2)
Prefetch(1,1)
#endregion

Crop(10, 4, -12, -2)
Prefetch(4,8)
#region DeHalo
Import("C:\StaxRip\Apps\Plugins\avs\DeHaloAlpha\Dehalo_alpha_MT2.avsi")
DeHalo_alpha(rx=2.0, ry=2.0, darkstr=1.2, brightstr=1.2, lowsens=50, highsens=50, ss=2.0)
Prefetch(1,1)
#endregion

#HQDeringmod(tv_range=true, nrmode=1, sharp=1, drrep=24) older
#lower threshold:more dering, min 30
#region HQDeringMod
HQDeringmod(Y=3,U=3,V=3, tv_range=true, mthr=60, mrad=2, minp=2, show=false)
Prefetch(2,4)
#endregion

#region EdgeCleaner
Import("C:\StaxRip\Apps\Plugins\AVS\EdgeCleaner\EdgeCleaner.avs")
EdgeCleaner(strength=30, rmode=17, smode=1, hot=true)
Prefetch(2,4)
#endregion

#region KNL denoising XD
#a = Trim(000000, 202192).KNLMeansCL(D = 4, A = 1, h = 1.2) #LOW
#d = Trim(202193, 205387).KNLMeansCL(D = 4, A = 3, h = 3.0) #HIGH
#e = Trim(205388, 298391).KNLMeansCL(D = 4, A = 1, h = 1.2) #LOW
#h = Trim(298392, 341051).KNLMeansCL(D = 9, A = 4, h = 3.0) #HIGH
#k = Trim(341052, 411149).KNLMeansCL(D = 4, A = 1, h = 1.2) #LOW
#UnalignedSplice(a,d,e,h,k)
#endregion

#KNLMeansCL(D = 4, A = 1, h = 1.2)
#night time
#KNLMeansCL(D = 15, A = 3, h = 3.0)
##ResizeTo444() <- e suposto existir
#BicubicResize(636, 474, 1.0, 0.0)

#region horizontal stretching
BicubicResize(636, 474, 0, 0)
#GaussResize(636, 474, p=60)
#endregion

#region Neo Flash Sankyuu
LoadPlugin("C:\StaxRip\Apps\Plugins\AVS\Neof3kdb\neo-f3kdbICC.dll")
neo_f3kdb(preset="low", range=12, dither_algo=2, keep_tv_range=true, random_algo_ref=2,random_algo_grain=2, opt=3)
Prefetch(2,4)
#endregion

#LoadPlugin("C:\StaxRip\Apps\Plugins\avs\SmoothAdjust\SmoothAdjust.dll")
#SmoothLevels(preset="tv2pc", Lmode=3, useOPT=3, debug=false)
#SmoothTweak(saturation=1.075, contrast=1.075, Lmode=0, useOPT=3, TVrange=false)
#SmoothTools(useOPT=3, debug=false)
SetMemoryMax(8192, DEV_TYPE_CPU)
Prefetch(1,1)
