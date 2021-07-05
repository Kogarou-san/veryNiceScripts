SetLogParams("Z:\AVSlog.txt", 4)

va = LWLibavVideoSource("kai-002.mkv", threads=2, prefer_hw=1)
vb = LWLibavVideoSource("kai-003.mkv", threads=2, prefer_hw=1)
aa = LWLibavAudioSource("kai-002.mkv")
ab = LWLibavAudioSource("kai-003.mkv")
a = AudioDub(va,aa)
b = AudioDub(vb,ab)
UnalignedSplice(a,b)

ConvertBits(16)
#Kogarou_yv12pointsamplingnnfix(interlaced=true, mode=3) #intended to fix really bad chroma subsampling, but this wasnt enough. Trying to find ways of fixing it currently
noisy=last
NotSMDegrain(interlaced=true, tr=6,thSAD=100, prefilter=3, MCContraSharp=true, str=6.0, Amp=0.1, refinemotion=true)
Kogarou_FreqMerge(noisy,last, chroma=true)
Prefetch(2,4)

TFM(mode=1, PP=3, slow=2, blockx=32, blocky=32, metric=0, MI=35, clip2=BWDIF(), display=false)
Prefetch(1,5)
TDecimate(mode=0,opt=4)
Vinverse_avsi()
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
Kogarou_FreqMerge(unbanded,last, chroma=true)
ConvertBits(bits=8, dither=0) #ordered dither looks more appealing. Dithering down to 8 bit for comparisons, all my filtering is done in 16-bit and outputs 10 bit

#Subtract(a,b)
#Compare(b,a)
ConvertBits(bits=8, dither=0)
SetMemoryMax(7168)
Prefetch(1,2)
#fix no blue artifacting na 1st scene da Rena
FreezeFrame(20085,20085,20087)
FreezeFrame(20086,20086,20088)