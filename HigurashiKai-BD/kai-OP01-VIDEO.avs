SetLogParams("Z:\AVSlog.txt", 4)

v=LWLibavVideoSource("kai-001.mkv", threads=2, prefer_hw=1)
a=LWLibavAudioSource("kai-001.mkv")
AudioDub(v,a)

#OP-specific framefreezes
FreezeFrame(146,146,147)
FreezeFrame(148,149,147)

ConvertBits(16)
#Kogarou_yv12pointsamplingnnfix(interlaced=true, mode=3) #intended to fix really bad chroma subsampling, but this wasnt enough. Trying to find ways of fixing it currently
noisy=last
NotSMDegrain(interlaced=true, tr=6,thSAD=100, prefilter=3, MCContraSharp=true, str=6.0, Amp=0.1, refinemotion=true)
Kogarou_FreqMerge(noisy,last)
Prefetch(2,4)

TFM(mode=1, PP=3, slow=2, blockx=32, blocky=32, metric=0, MI=20, clip2=BWDIF(), display=false, ovr="C:\Temp\HigurashiKai\CombedFramesOP.txt", ovrDefault=1)
Prefetch(1,5)
TDecimate(mode=0,opt=4)
Vinverse_avsi()
FreezeFrame(0,1,1) #OP
Prefetch(1,5)

Kogarou_xaa(mode="sr 1 nnedi3",  ss=2, nns=0, chroma=1, csharp=1)
ConvertToStacked()
HQDeringmod(Y=3,U=3,V=3, lsb_in=true, lsb=true, mthr=60,sharp=3)
ConvertFromStacked()
Prefetch(1,2)

nnedi3_resize16(864, 480, nns=1, sharp=15, matrix="601") #stretch back the frames back to the original AR
EdgeCleaner(strength=20, rmode=1, smode=1, hot=true) #mild dehaloing
Prefetch(1,2)

unbanded=last
Kogarou_AdaptiveGrain(sankyuuY=48, sankyuuC=32, luma_scaling=4)
Prefetch(1,2)
Kogarou_FreqMerge(unbanded,last)
ConvertBits(bits=10, dither=0) #ordered dither looks more appealing 
SetMemoryMax(5120)
Prefetch(1,2)
Trim(119,Framecount)

#StackHorizontal(last.ExtractY(),StackVertical(last.ExtractU(), last.ExtractV())) #chroma testing, 420
#StackHorizontal(last.ExtractY(),last.ExtractU(),last.ExtractV()) #chroma testing, 444
#similar frame freeze eheh, after filtrar. removing slight uneeded changes
FreezeFrame(198,199,198)
FreezeFrame(409,410,409)
FreezeFrame(416,420,416)
FreezeFrame(421,423,421)
FreezeFrame(620,622,620)
FreezeFrame(639,640,639)
FreezeFrame(787,788,787)
FreezeFrame(1215,1225,1215)
FreezeFrame(1226,1227,1226)
FreezeFrame(1228,1238,1228)
FreezeFrame(1239,1240,1239)
FreezeFrame(1241,1251,1241)
FreezeFrame(1252,1253,1252)
FreezeFrame(1688,1689,1688)
FreezeFrame(1714,1715,1714)
FreezeFrame(2159,2178,2159)