SetLogParams("Z:\AVSlog.txt", 4)
#~ Remember kids, never do one-liners, learn from others mistakes, like this one
#~ qt = DeleteFrame(FrameCount-1).SelectEven().QTGMC(Preset="Slower")
LoadPlugin("C:\StaxRip\Apps\Support\DGDecNV\x64\DGDecodeNV.dll")

DGSource("kai-002.dgi", deinterlace=0,show=false)
#audio = LWLibavAudioSource("kai-002.mkv")

qt = OnCPU(2).KTGMC(Preset="Slower", NNSize=3, NNeurons=4, EdiQual=2, Lossless=0, SourceMatch=0,    \
TR0=2, TR1=2, TR2=2, Rep0=1, Rep1=1, Rep2=1, SubPel=2, PelSearch=2,        \
MatchPreset="Slower", MatchPreset2="Slower", DenoiseMC=true, Denoiser="dfttest", FPSDivisor=2).OnCUDA(2) #forbidden line
TFM(PP=5,slow=2, clip2=qt)
TDecimate(mode=1)
Prefetch(1,3)

#1=border, 2=inside, alpha, beta
Deblock_QED(quant1=32,quant2=28, aOff1=2,aOff2=1, bOff1=2,bOff2=1, uv=-1)
#Mosquito()
EdgeCleaner(strength=10, rmode=17, smode=1, hot=true)
xaa(mode="sr 1 nnedi3", nns=0, chroma=0) # sr 1 pass parece ser o ideal
Prefetch(1,3)
	SMDegrain(tr=3,thSAD=100, prefilter=3, contrasharp=true,str=3.0, refinemotion=true,lsb_out=true, mode=6)
	Prefetch(2,4)
	UpscaleTo444()
	nnedi3_resize16(864, 480, nns=0, sharp=100, matrix="601", lsb=true,lsb_in=true )
	Prefetch(2,4)
	SmoothGrad(radius=16,elast=3.00, stacked=true)
	Prefetch(1,3)
	ConvertFromStacked()
	#Toon(strength=48, sharpen=false)
	neo_f3kdb(seed=1337, dither_algo=3, keep_tv_range=true, y=64, cb=32, cr=32, grainy=32, grainc=16, output_depth=16)
	Prefetch(1,3)
	
#AudioDub(last,audio)
SetMemoryMax(8192, DEV_TYPE_CPU)