#frame 56145
LWLibavVideoSource("X:\gaki no tsukai RAW\dvd1\24htag.mkv_t00.mkv", threads=2)
AssumeTFF()
ConvertBits(16)

Prefetch(1,7)

noisy=last
#pre-denoising/very light deblocking, QTGMC also does it but havent tested how good it is there.
#FreqMerge gets the original high frequency detail from the source clip and adds it back to the filtered clip. in this case it will end up adding all the blocking's outer edges, but the intent is to add back
#removed, weak lines lines after MDegrain's denoising
NotSMDegrain(interlaced=true,tr=3, prefilter=3,MCcontrasharp=true, str=6.0, Amp=0.1, refinemotion=true, mode=6) 
Kogarou_FreqMerge(noisy,last)

#DFTtest seems to do a better job than QED even like this, but I haven't been thorough with it. QTGMC's denoising is also as good it seems
#Deblock_QED(quant1=32, quant2=32, aOff1=3, aOff2=3, bOff1=3, bOff2=3, exdeblock1="dfttest(sigma=32, tbsize=11,sbsize=16, sosize=8,dither=1)", exdeblock2="dfttest(sigma=128, tbsize=11,sbsize=16, sosize=8,dither=1)")
#LUTDeRainbow(cthresh= 20, linkUV=false,mask=true) #used it before, for some zones, dubious changes, havent tried it again


#region QTGMC
#slower stuff consooms way 2 much RAM
QTGMC(Preset="Slower", NNSize=3, NNeurons=4, Lossless=0, SourceMatch=0, TR0=0, TR1=2, TR2=3, Rep0=53, Rep1=53, Rep2=53, SubPel=4, TrueMotion=true, SrchClipPP=3, PelSearch=4,  ShowSettings=false, keep_tv_range=true, ShowNoise=false, EZDenoise=3.0, Denoiser="dfttest", DenoiseMC=true, ChromaNoise=true, Sigma=18, NoiseTR=2, NoiseProcess=1,StabilizeNoise=true)
Prefetch(4,4)
nnedi3_resize16(640,480)
#Cropping the borders
BicubicResize(width(),height(),0,0,4,0,width(),height())
Crop(0,6,-12,0)

noisy=last
Y=noisy.ExtractY().FineDehalo(contra=1).FineDehalo(contra=1)
U=noisy.ExtractU().FineDehalo(contra=1).FineDehalo(contra=1)
V=noisy.ExtractV().FineDehalo(contra=1).FineDehalo(contra=1)
CombinePlanes(Y, U, V, planes="YUV", source_planes="YYY", sample_clip=noisy)
Prefetch(1,2)
FineDehalo2()
Kogarou_FreqMerge(noisy,last) #experimental
#Subtract(noisy,last)
EdgeCleaner(strength=30, rmode=1, smode=1, hot=true) #experimental cleaning of the edges
EdgeCleaner(strength=30, rmode=17, smode=1, hot=true)

#--- warning: everything down here comes from my older script, it's untranslated and not great ---


/*
#frame 56145

#WIP convertion para avs neo
DGSource("X:\gaki no tsukai RAW\dvd1\24htag.mkv_t00_temp\24htag.mkv_t00.dgi", deinterlace=0)
#QTGMC(Preset="Draft", ShowSettings=false, Precise=false, TR0=1, TR2=2, Rep0=1, Rep2=1,EdiMode="NNEDI3", ChromaEdi="NNEDI3", NNSize=3, NNeurons=1)

#region De-rainbow

#DeCross(ThresholdY=30, Noise=60, Margin=1, Debug=false ) #DeCross must be used right after the source filter, before any field matching or deinterlacing. The luma channel is returned unchanged.

AssumeFieldBased()


#dfttest(sigma=48, tbsize=11,sbsize=16, sosize=8,dither=1).Weave() #strong
#dfttest(sigma=8, tbsize=11,sbsize=16, sosize=8,dither=1).Weave() #strong
#neo_dfttest(sigma=16, tbsize=7)#.AssumeFieldBased().Weave()
#AutoDeblock3(debug=true)
#noisy=last
Deblock_QED(quant1=32, quant2=32, aOff1=3, aOff2=3, bOff1=3, bOff2=3, exdeblock1="dfttest(sigma=32, tbsize=11,sbsize=16, sosize=8,dither=1)", exdeblock2="dfttest(sigma=128, tbsize=11,sbsize=16, sosize=8,dither=1)")
#FreqMerge(noisy,last)
#Deblock_QED(quant1=36, quant2=36, aOff1=3, aOff2=3, bOff1=3, bOff2=3, exdeblock1="dfttest(sigma=32, tbsize=11,sbsize=16, sosize=8,dither=1)", exdeblock2="dfttest(sigma=48, tbsize=11,sbsize=16, sosize=8,dither=1)")
#dfttest(sigma=48, tbsize=11,sbsize=16, sosize=8,dither=1)
AssumeFieldBased()
Weave()#HQDN3D(ls=2,lt=2)
AssumeTFF()

#LUTDeRainbow(cthresh= 20, linkUV=false,mask=true)
Prefetch(1,2)
#endregion

#region KTGMC
#slower stuff consooms way 2 much VRAM
Prefetch(1,2)
QTGMC(Preset="Slower", EdiMode="NNEDI3", NNSize=3, NNeurons=4, Lossless=0, SourceMatch=0, TR0=0, TR1=2, TR2=3, Rep0=53, Rep1=53, Rep2=53, SubPel=4, TrueMotion=true, SrchClipPP=3, PelSearch=4, DenoiseMC=true, Denoiser="dfttest",ShowSettings=false, keep_tv_range=true)
#NNEDI3(-2)
#NNEDI3(field=-1, nsize=3,nns=4)
#for some reason QTGMC makes ultra big halos
Prefetch(2,4)


Prefetch(3,6)
xaaKMOD(mode="sr 1 nnedi3",  ss=2, nns=0, chroma=1, csharp=1, mthr=7) # sr 1 pass parece ser o ideal
Prefetch(2,4)
#Crop(10, 4, -12, -2)
EdgeCleaner(strength=30, rmode=1, smode=1, hot=true)
#HalobusterKogarouMod()
#DeHaloHmod(Maska = false, mode=1, dirty=true)
Prefetch(2,4)






#region KNL denoising XD
#KNLMeansCL(D = 2, A = 8, h = 1.8)
#a = Trim(000000, 202192).KNLMeansCL(D = 4, A = 1, h = 1.2) #LOW
#d = Trim(202193, 205387).KNLMeansCL(D = 4, A = 3, h = 3.0) #HIGH
#e = Trim(205388, 298391).KNLMeansCL(D = 4, A = 1, h = 1.2) #LOW
#h = Trim(298392, 341051).KNLMeansCL(D = 9, A = 4, h = 3.0) #HIGH
#k = Trim(341052, 411149).KNLMeansCL(D = 4, A = 1, h = 1.2) #LOW
#UnalignedSplice(a,d,e,h,k)
#endregion

#c = StackVertical(ExtractU(), ExtractV())
#y = ExtractY()
#StackHorizontal(y,c)

#KNLMeansCL(D = 4, A = 1, h = 1.2)
#night time
#KNLMeansCL(D = 15, A = 3, h = 3.0)
##ResizeTo444() <- e suposto existir
#BicubicResize(636, 474, 1.0, 0.0)

#region horizontal stretching
#BicubicResize(636, 474, 0, 0)
#GaussResize(636, 474, p=60)
#endregion

#region Neo Flash Sankyuu

#neo_f3kdb(preset="low", range=12, dither_algo=2, keep_tv_range=true, random_algo_ref=2,random_algo_grain=2, opt=3)
Prefetch(2,4)
#endregion


#ConvertToYUV444()
#Crop(4,2,-8,0)
#BalanceBorders(0,0,1,1)
#FixColumnBrightnessProtect2(1,20)


#FixColumnBrightnessProtect2(0,0)
#FixColumnBrightnessProtect2(630,0)
#FixRowBrightnessProtect2(0,0)
#a=SelectOdd().BalanceBorders(1,0,0,0).FixRowBrightnessProtect2(2,-1).FixRowBrightnessProtect2(1,-6).FixRowBrightnessProtect2(0,-4)
#b=SelectEven().FixRowBrightnessProtect2(1,-7)
#Interleave(b,a)
#FixRowBrightnessProtect2(0, 20)
#LoadPlugin("C:\StaxRip\Apps\Plugins\avs\SmoothAdjust\SmoothAdjust.dll")
#SmoothLevels(preset="tv2pc", Lmode=3, useOPT=3, debug=false)
#SmoothTweak(saturation=1.075, contrast=1.075, Lmode=0, useOPT=3, TVrange=false)
#SmoothTools(useOPT=3, debug=false)
SetMemoryMax(6096)
Prefetch(1,1)
*/