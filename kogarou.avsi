#here are my own functions

#modified to support HBD video natively instead of LSB hacks
FUNCTION Kogarou_yv12pointsamplingnnfix(clip srco, bool "interlaced", bool "top", bool "left", int "mode", bool "leftshift", int "qual", int  "nns", int "nsize", int "etype", int "pscrn", bool "eed", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", int "nrad", int "mdis", float "alpha", float "beta", float "gamma", int "nnrep", int "Threads" ) {
interlaced    = default(interlaced, false)
eed           = default(eed,      false)
top           = default(top,       true)
left          = default(left,      true)
mode          = default(mode,         1)
mode25        = mode==4 || mode==5 ? 2 : mode
leftshift     = default(leftshift, left)
nnrep         = Default(nnrep, 0)
Threads       = default( Threads, sh_GetUserGlobalIMTint(true))


src = interlaced ? srco.SeparateFields().AssumeFrameBased() : srco

chromay8 = mode==3 || mode==1 ? Interleave(src.ExtractU(),src.ExtractV()) : nop()

chromay8n = mode==3 || mode==1 ? chromay8.sh_Padding(2,2,2,2,Threads) : chromay8
chromay8n = mode==3 || mode==1 ? chromay8n.nnedi3(field=top ? 1 : 0,dh=true, qual=qual, nns=nns, nsize=nsize, etype=etype, pscrn=pscrn, Threads=Threads ).crop(2,4,-2,-4,true) : chromay8n
chromay8e = (mode==3 || mode==1) && eed ? chromay8.EEdi3(field=top ? 1 : 0,dh=true,sclip=chromay8n,u=false,v=false,vcheck=vcheck, nrad=nrad, mdis=mdis, alpha=alpha, beta=beta, gamma=gamma, vthresh0=vthresh0, vthresh1=vthresh1, vthresh2=vthresh2, Threads=Threads) : chromay8n
chromay8 = (mode==3 || mode==1) && eed && nnrep > 0 ? nnrep > 1 ? slimit_dif2(chromay8e,chromay8n,thr=4) : chromay8e.Repair(chromay8n,9) : chromay8e

chromay8 = mode25==2 || mode==3 ? Eval("try { fTurnRight(mode==3 ? chromay8 : Interleave(src.UToY8(),src.VToY8()), mt=threads!=1) } catch(error_msg) { TurnRight(mode==3 ? chromay8 : Interleave(src.UToY8(),src.VToY8())) }") : chromay8

chromay8n = mode25==2 || mode==3 ? chromay8.sh_Padding(2,2,2,2,Threads) : chromay8
chromay8n = mode25==2 || mode==3 ? chromay8n.nnedi3(field=left ? 1 : 0,dh=true, qual=qual, nns=nns, nsize=nsize, etype=etype, pscrn=pscrn, Threads=Threads ).crop(2,4,-2,-4,true) : chromay8n
chromay8e = (mode25==2 || mode==3) && eed ? chromay8.EEdi3(field=left ? 1 : 0,dh=true,sclip=chromay8n,u=false,v=false,vcheck=vcheck, nrad=nrad, mdis=mdis, alpha=alpha, beta=beta, gamma=gamma, vthresh0=vthresh0, vthresh1=vthresh1, vthresh2=vthresh2, Threads=Threads) : chromay8n
chromay8 = (mode25==2 || mode==3) && eed && nnrep > 0 ? nnrep > 1 ? slimit_dif2(chromay8e,chromay8n,thr=4) : chromay8e.Repair(chromay8n,9) : chromay8e

chromay8 = mode25==2 || mode==3 ? Eval("try { fTurnLeft(chromay8, mt=threads!=1) } catch(error_msg) { TurnLeft(chromay8) }") : chromay8

chrshifting = mode25==2 ? mode==5 ? undefined : leftshift ? mode==4 ? -0.25 : -0.5 : mode==4 ? 0.25 : 0.5 : nop()
chromay8 = mode25==2 ? chromay8.BilinearResize(width(chromay8)/2,height(chromay8),src_left=chrshifting) : chromay8
#chromaup = YToUV(chromay8.SelectEven(),chromay8.SelectOdd(),src.ConvertToY8())
chromaup = CombinePlanes(src.ExtractY(), chromay8.SelectEven().ExtractY(), chromay8.SelectOdd().ExtractY(), planes = "YUV", source_planes = "YYY", sample_clip=chromay8.ConvertToYUV444())
return interlaced ? GetParity(srco) ? chromaup.AssumeFieldBased().AssumeTFF().Weave() :  chromaup.AssumeFieldBased().AssumeBFF().Weave() : chromaup
}


#since edi_rpow2 dropped tryFTurn, here it stays for compatibility's sake, not that FTurn itself is gonna run, but the scripts won't unless FTurn is defined. 
# Functions to use FTurn if available or else fall back to the internal turn functions
function TryFTurnLeft(clip c, bool "chroma") {
try { 
    return c.FTurnLeft(chroma=chroma)
    }
catch(err_msg) {
    return c.TurnLeft()
    }
}

function TryFTurnRight(clip c, bool "chroma") {
try { 
    return c.FTurnRight(chroma=chroma)
    }
catch(err_msg) {
    return c.TurnRight()
    }
}

function TryFTurn180(clip c, bool "chroma") {
try { 
    return c.FTurn180(chroma=chroma)
    }
catch(err_msg) {
    return c.Turn180()
    }
}



function Kogarou_Halobuster(clip input, int "a", float "h", float "thr", float "elast", clip "predehalo")
{
	# HBD mod, and others
	# 2020.11.04
	#rewrite of https://forum.doom9.org/showthread.php?t=172599 to be more readable and add native HBD support, only works properly with AVS+
	#requires https://raw.githubusercontent.com/realfinder/AVS-Stuff/master/avs%202.5%20and%20up/Zs_RF_Shared.avsi for svsTcanny

	sislumaonly = input.isy() 
	exdhb = defined(predehalo)
	a= Default (a, exdhb ? 8 : 32)
	h = Default(h, 6.4)
	thr = Default(thr, 1.0)
	elast = Default(elast, 1.5)
	
	
	
	rclip = exdhb ? !sislumaonly ? predehalo.converttoy() : predehalo : undefined
	rclip = exdhb ? rclip.sh_padding (a, a, a, a) : rclip
	gray = sislumaonly ? input : input.converttoy()
	gray = gray.sh_padding (a, a, a, a)
	clean = knlmeanscl (gray, d=0, a=a, s=0, h=h, rclip=rclip)
	mask = svsTcanny (clean, sigma=1.5, mode=1, gmmax=50)
	mask = mt_lut (mask, "x range_max / 0.24 - 3.2 * 0.0 max 1.0 min range_max *", use_expr=2)
	mask = mt_expand (mask)
	mask = mt_inflate (mask)
	merge = mt_merge (gray, clean, mask)
	limit = slimit_dif(gray, merge, thr=thr, elast=elast)
	crop = crop(limit, a, a, -a, -a, true)
	final = sislumaonly ? crop : CombinePlanes(crop,input,planes="YUV",sample_clip=input) 

	return final
}

function Kogarou_FreqMerge(clip "low", clip "high", bool "chroma", int "sbsize", int "dftThreads", int "fftThreads")
{
	#AVS+ port of https://github.com/IFeelBloated/Oyster/blob/7d52c78cb1eb27750d503ed6b36cc443d29140bf/Oyster.py#L42
	#usage of prefetch(1) is recommended for original DFTtest, should be perfectly fine to use more with neo_DFTtest
	#1st arg = detailed clip, 2nd arg = denoised clip in which to re-add back the details/high frequency content
	#chroma toggle to enable or disable chroma freqmerging, if disabled, the chroma from "high" clip will be used in the return statement
	
	#edit 1: new param "chroma", default false, behaviour as I originally implemented. Faster
	#true: does freqmerge in chroma too
	
	chroma=default(chroma,false)
	dftThreads = default(dftThreads,1)
	fftThreads = default(fftThreads,1)
	
	if(chroma==false)
	{
		orig=high
		U=high.ExtractU()
		V=high.ExtractV()
		high=high.ExtractY()
		low=low.ExtractY()
		
		hif=neo_dfttest(high, sbsize=sbsize, threads=dftThreads, U=1,V=1, opt=3)
		final=neo_dfttest(low, sbsize=sbsize, threads=dftThreads, U=1,V=1, opt=3)
		
		hif = mt_makediff(high,	hif, U=1,V=1)
		final = mt_adddiff(final, hif, U=1,V=1)
		
		return CombinePlanes(final,U,V, planes="YUV", source_planes="YYY", sample_clip=orig)
	}
	else
	{
		orig=high

		hif=neo_dfttest(high, sbsize=sbsize, threads=dftThreads, U=3,V=3, opt=3)
		final=neo_dfttest(low, sbsize=sbsize, threads=dftThreads, U=3,V=3, opt=3)
		
		hif = mt_makediff(high,	hif, U=3,V=3)
		final = mt_adddiff(final, hif, U=3,V=3)
		
		return final
	}
}

function Kogarou_AdaptiveGrain(clip input, int "sankyuuY", int "sankyuuC", int "luma_scaling", float "AddGrainLuma")
{
	#Since Higurashi Kai has banding issues in ALL planes, it's useful to have a function that tackles it better
	#than to just throwing flashSankyuuDeband on it, since it has a tendency to remove lighter details like that
	#case in point: frame 1045 of the OP, gets its clothing's light gradients completely gone and ugly
	#Kage's AdaptiveGrain doesnt do different settings for chroma IIRC? hence this modification
	#the only grain option is locked to neo_f3kdb, since otherwise I'd use the normal AdaptiveGrain function
	#AdaptiveGrain.avsi: # luma (default false): If true the luma mask is used for chroma too.
	#It doesnt seem to work for the issue above but OK i guess
	
	AddGrainLuma	= default(AddGrainLuma, 0.30	)
	luma_scaling	= default(luma_scaling, 4		)
	sankyuuY		= default(sankyuuY,		48		)
	sankyuuC		= default(sankyuuC,		32		)
	
	Y=input.ExtractY()
	Y=AdaptiveGrain(Y,grain=neo_f3kdb(Y, seed=1337, dither_algo=2, keep_tv_range=true, grainy=sankyuuY, y=sankyuuY, preset="luma"), luma_scaling=luma_scaling,luma=false, mask8=false, show=false)
	UV=				  input.neo_f3kdb(seed=1337, dither_algo=2, keep_tv_range=true,	grainc=sankyuuC, cb=sankyuuC,cr=sankyuuC, preset="chroma")
	U=UV.ExtractU()
	V=UV.ExtractV()
	return CombinePlanes(Y,U,V, planes="YUV", source_planes="YYY",sample_clip=input)
}



############### z.lib wrappers ###############
function zBilinear(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bilinear", cpu_type="avx2", approximate_gamma=false)}

function zBicubic(clip input, int "Width", int "Height", int "b", int "c")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=b, filter_param_b=c, cpu_type="avx2", approximate_gamma=false)}

function zMitchell(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=1/3, filter_param_b=1/3, cpu_type="avx2", approximate_gamma=false)}

function zCatmull(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0, filter_param_b=1/2, cpu_type="avx2", approximate_gamma=false)}

function zHermite(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0, filter_param_b=0, cpu_type="avx2", approximate_gamma=false)}

function zBetaSpline(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=1, filter_param_b=0, cpu_type="avx2", approximate_gamma=false)}

function zPreciseBicubic(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0, filter_param_b=3/4, cpu_type="avx2", approximate_gamma=false)}

function zSharpBicubic(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0, filter_param_b=1, cpu_type="avx2", approximate_gamma=false)}

function zRobidouxSoft(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0.6796, filter_param_b=0.1602, cpu_type="avx2", approximate_gamma=false)}

function zRobidoux(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0.3782, filter_param_b=0.3109, cpu_type="avx2", approximate_gamma=false)}

function zRobidouxSharp(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="bicubic", filter_param_a=0.2620, filter_param_b=0.3690, cpu_type="avx2", approximate_gamma=false)}

function zSpline16(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="spline16", cpu_type="avx2", approximate_gamma=false)}

function zSpline36(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="spline36", cpu_type="avx2", approximate_gamma=false)}

function zSpline64(clip input, int "Width", int "Height")
	{return z_ConvertFormat(input, Width,Height, resample_filter="spline64", cpu_type="avx2", approximate_gamma=false)}

function zLanczos(clip input, int "Width", int "Height", int "taps")
	{return z_LanczosResize(input, Width,Height, resample_filter="lanczos", filter_param_a=taps, cpu_type="avx2", approximate_gamma=false)}
############### ############## ###############


###---WARNING: THE FUNCTIONS BELOW ARE OUTDATED/DEPRECATED/USELESS after new ways of filtering were discovered and/or implemented by me.---###
###---They'll stay in here to show what I used to do and write before. No point in translated my portuglish too, dont worry about that. ---###

function Mosquito(clip input)
{
	#forma mais facil de chamar MosquitoNR()
	
	U = input.ExtractU()
	V = input.ExtractV()
	
	Y = input.MosquitoNR(threads=2)
	U = U.MosquitoNR(threads=2)
	V = V.MosquitoNR(threads=2)
	
	if(Y.Height>U.Height)
		{return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV420P8")}
	else
		{return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV444P16")}
}

function HigurashiScaler(clip input, int "Width", int "Height", float "Sharp", bool "lsb_in", bool "lsb_out", bool "HBD") #aka DVD rescaler
{
	#apesar de se chamar HiguUpscaler, e so mesmo para dar upscale de YUV420P16 DVDs em 1.5AR ja denoised
	#com SMDegrain para YUV444P16 com non-DVD AR
	#P.s. input tem que ser Stack16
	#nnedi3_resize16 suporta tanto Stack16 (either input ou output) como suporta native HBD (para dar output em HBD, tem que receber HBD too)
	
	
	Width	= default(Width,	0	)
	Height	= default(Height,	0	)
	Sharp	= default(Sharp, 	15.0)
	HBD		= default(HBD, 		false)
	lsb_in	= default(lsb_in,	false)
	lsb_out	= default(lsb_out,	false)
	if(HBD==true)
	{
		lsb_in=false
		lsb_out=false
	}
	
	Assert(Width!=0	, "HigurashiScaler: missing target clip's Width")
	Assert(Height!=0, "HigurashiScaler: missing target clip's Height")
	
	if((lsb_in==true || lsb_out==true) && HBD==true)
		{Assert(false, "HigurashiScaler: you can't enable both native HBD and Stack16")}
	
	
	
	if (HBD==true)
	{
		return nnedi3_resize16(input, Width, Height, nns=1, sharp=Sharp, matrix="601", output="YV24")
	}
	else if(lsb_in==true || lsb_out==true)
	{
		return nnedi3_resize16(input, Width, Height, nns=1, sharp=Sharp, matrix="601", lsb=lsb_out, lsb_in=lsb_in, output="YV24")
	}
	
}

function WideDVDScaler(clip input)
{
	#O que faz:
	#Dá upscale com NNEDI3 para os lados e de seguida dá downscale com Hermite, de forma a ajustar o AR
	#de volta para ficar com 1:1 pixels.
	#também faz upscale ao chroma, que já e pretty low, e por isso parece ser uma boa ideia não o manter
	#tão pequeno,
	#as it stands, agarra num 1.5 SAR 4:2:0 DVD para fazer um 1.7(7) DAR 4:4:4 DVD
	#Hermite é ideal pelo lack of ringing, mas ainda nao experimentei SSIM com softer settings.
	#O ChromaShift da fix ao shift causado pelo NNEDI3 ao dar upscale ao chroma back to 4:4:4
	
	#_fixShift=default(fixShift,true)
	if(input.BitsPerComponent==16)
	{
		#KNNEDI3 aparentemente nao e compativel com high bit depth :smile:
		#experimental shader based NNEDI3
		#edit nao corre L
		
		input = input.TurnLeft().NNEDI3(field=0, dh=true, nsize=0, nns=2, pscrn=2, qual=1)

		Y = input.ExtractY().TurnRight()
		U = input.ExtractU()
		V = input.ExtractV()
		
		U = U.NNEDI3(field=0, dh=true, nsize=0, nns=2, pscrn=2, qual=1).TurnRight().NNEDI3(field=0, dh=true, nsize=0, nns=2, pscrn=2, qual=1)
		V = V.NNEDI3(field=0, dh=true, nsize=0, nns=2, pscrn=2, qual=1).TurnRight().NNEDI3(field=0, dh=true, nsize=0, nns=2, pscrn=2, qual=1)

		return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV444P16")
	}
	
	if(input.BitsPerComponent==8)
	{
		Y = input.ExtractY()
		U = input.ExtractU()
		V = input.ExtractV()
		
		Y = Y.TurnLeft()
		Y = Y.OnCPU(2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).OnCUDA(2)
		Y = Y.TurnRight()
		
		
		U = U.OnCPU(2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).OnCUDA(2)
		U = U.TurnLeft()
		U = U.OnCPU(2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).OnCUDA(2)
		U = U.TurnRight()
		
		
		V = V.OnCPU(2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).OnCUDA(2)
		V = V.TurnLeft()
		V = V.OnCPU(2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).KNNEDI3(field=0, dh=true, nsize=0, nns=4, pscrn=4, qual=2).OnCUDA(2)
		V = V.TurnRight()
	
		return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV444P8")
	}
	#hack especifico para o higurashi Kai
	
	#ResizeShader(864, 480, Kernel="SSIM", MatrixIn="Rec601",MatrixOut="Rec601")
	#stop looking please
	
	#if(_fixShift==true)
	#{
		#BicubicResize(_x, _y, b=0,c=0)
	#	return ChromaShiftSP(X=0.5)
	#}
	#else
	#{
		#return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV444P8")
		#return BicubicResize(_x, _y, b=0,c=0)
	#}
	
}

function Deemphasize2way(clip c, int "strength", bool "interlaced", bool "tff")
{
  strength = default(strength, 95)
  strength = strength < 0 ? -strength : strength
  strength = strength >= 100 ? 0 : 100-strength
  tff = default(tff, false)
  interlaced = default(interlaced, false)
  c = interlaced ? (tff ? c.AssumeTFF().SeparateFields() : c.AssumeBFF().SeparateFields()) : c
  mask = c.mt_edge("1 0 -1 2 0 -2 1 0 -1", 0, 255, 0, 255)
  mask = mask.mt_inpand(mode="both")\
             .mt_inpand(mode="both")\
             .mt_inpand(mode="both")\
             .mt_expand(mode="both")\
             .mt_expand(mode="both")\
             .mt_expand(mode="both")
  blurred = c.GaussResize(c.width-2, c.height-2, p=strength).Spline36Resize(c.width, c.height)
  output = mt_merge(blurred, c, mask)
  return interlaced ? output.Weave() : output
}

function UpscaleTo444(clip input)
{
	#buggy, fucks up pixels in the bottom row
	if(input.BitsPerComponent==16)
	{
		#KNNEDI3 aparentemente nao e compativel com high bit depth :smile:
		#experimental shader based NNEDI3
		#edit nao corre L

		Y = input.ExtractY()
		U = input.ExtractU()
		V = input.ExtractV()
		
		U = U.TurnLeft().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1).TurnRight().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1)
		V = V.TurnLeft().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1).TurnRight().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1)

		return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV444P16")
	}
	
	if(input.BitsPerComponent==8)
	{
		Y = input.ExtractY()
		U = input.ExtractU()
		V = input.ExtractV()
		
		U = U.TurnLeft().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1).TurnRight().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1)
		V = V.TurnLeft().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1).TurnRight().NNEDI3(field=0, dh=true, nsize=0, nns=0, pscrn=2, qual=1)
	
		return CombinePlanes(Y, U, V, planes = "YUV", source_planes = "YYY", pixel_type = "YUV444P8")
	}
}