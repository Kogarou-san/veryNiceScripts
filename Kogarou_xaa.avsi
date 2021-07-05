/* xaa v1.2.1
	Mod by Kogarou to support newer plugins and HBD
	Has NO SUPPORT for AVS2.6, 32-bit AVS (possibly), NNEDI3OCL (since 32-bit only) or LSB hacks (since native HBD is a thing.)
	WARNING: THE SCRIPT HASN'T BEEN FULLY TESTED AGAISNT ALL ITS OPTIONS. THERE MIGHT BE OPTIONS THAT DONT WORK, LIKE OTHER EDIS THAN NNEDI3
A highly versatile antialiasing function.


##### Requirements #####

Plugins:
  REMOVED: Dither (because the purpose is to support native HBD
  eedi2
  eedi3
  REMOVED: FTurn
  MaskTools2
  nnedi3
  REMOVED: nnedi3ocl (because we're supporting 32-bit users as much as AVS2.6 users. Some1 plz port nnedi3cl from VS :) )
  RgTools
  SangNom2
  CHANGED: http://avisynth.nl/index.php/VsTCanny		instead of TCannyMod
  CHANGED: http://avisynth.nl/index.php/VsTEdgeMask		instead of TEMmod
  NOTE: the 2 latter plugins changed but to maintain compatibility with the original, the XAA args are going to name the
  original plugin names, even tho the script is using the newer, VS-ported ones. Also makes my job easier. Any mention of
  TCannyMod or TEMmod in this documentation will be referencing the original plugins.
Scripts:
  edi_rpow2
  ResizeX

REMOVED: FTurn is optional but recommended.
Other plugins not used with your chosen settings don't need to be loaded.

CHANGED: Color formats:
  Y8, YV12, YV16, YUY2, YV24
 
Supported color formats: Y8, YV12, YV16. YV24
    AviSynth+: all planar formats (8/10/12/14/16-bit, Y/YUV/RGB without an alpha channel) are supported. (Probably)


##### Parameters #####

int ow, int oh (defaults: input width, input height)
----------------------------------------------------
The output width and height.
Useful for when the video is going to be resized after antialising.
Use a negative value for either to disable resizing after supersampling.


float ss (default: 2.0)
-----------------------
The multiplier for determining the supersampled resolution which is then rounded to mod4.
Defaults to 1.0 (no supersampling) for double rate and double image antialiasing modes


val ssw, val ssh (defaults: ss)
-------------------------------
Allows separate control of the supersampled width and height. Overrides the ss value.
When specified as a float, they act as a multiplier like the ss parameter.
When specified as an int, the given value is used for the supersampled
width or height without rounding to mod4.


string mode (default: "sr SangNom2")
------------------------------------
Specifies how to perform antialiasing in the format "[aa mode][direction][passes] [type] [sclip]"
with the settings below available for each option. Antialiasing can also be disabled with "null"

AA Mode:   sr, dr, di
Direction: h, v, b
Passes:    1 to 9
Type:      SangNom2, nnedi3, eedi3, eedi2
Sclip:     SangNom2, nnedi3, eedi2, or any resize kernel

AA Mode
The antialiasing mode determines what method of antialiasing is used.
sr uses single rate deinterlacing, discarding one field of the frame and interpolating it from the remaining field.
dr uses double rate deinterlacing, interpolating full-height frames from both fields and then blending the two together.
di doubles the image height by interpolating every other line for the first pass, uses single rate deinterlacing 
for subsequent passes, and then downscales back to the original resolution.

Direction
By setting the direction to h or v, antialiasing can be applied only horizontally or vertically.
If the direction is set to b or omitted, antialiasing will be applied in both directions.

Passes
The more passes used, the stronger the antialiasing will be.
If the number of passes is omitted, it will default to 1.

Type
The type determines which deinterlacing plugin is used for antialiasing.

Sclip
The sclip option only applies when the type is set to eedi3 and will be undefined if omitted.
If specified, the given deinterlacer or resize kernel will be used to generate the sclip for eedi3.
See eedi3's documentation for more details.

Preset modes which change the default settings to mimic other antialiasing functions are also available:
"maa2, "daa", "Mrdaa" or "MrdaaLame", "santiag"

Equivalent settings
maa2:    xaa(mtype="sobel", mthr=7)
daa:     xaa(mode="drv nnedi3", csharp=1, mask=0, chroma=1)
Mrdaa:   xaa(mode="null", uscl="nnedi3", csharp=2, cstr=1.0, mask=0, chroma=1)
santiag: xaa(mode="di2 nnedi3", mask=0, chroma=1)


string uscl, string dscl (defaults: "Spline36")
-----------------------------------------------
The resize kernels used when upscaling, such as when supersampling, and when
downscaling, such as when scaling back to the input resolution after supersampling.
Supports all of AviSynth's internal resizers and ResizeX's bicubic presets, and for upscaling,
"nnedi3", "nnedi3ocl", "eedi3", and "eedi2" can also be used for their rpow2 image enlargement.

For the Lanczos, Blackman, and Sinc kernels, the number of taps can be set
with a number after the kernel name. E.g. "Blackman3" for BlackmanResize(taps=3).

For eedi3 upscaling, the sclip setting can be specified with a resize kernel name or edi method
on the end of the string. E.g. "eedi3 nnedi3" to upscale with eedi3 using nnedi3 as the sclip.


int csharp (default: 0)
-----------------------
0: No contra-sharpening.
1: Applies contra-sharpening before scaling to output resolution.
2: Applies contra-sharpening after scaling to output resolution.


float cstr (default: -1.0)
--------------------------
Controls the strength of the contra-sharpening.
Any negative value uses RemoveGrain(11) as in daa.
A positive value uses Blur as in Mrdaa up to a max of 7.9.
A value of 0 disables contra-sharpening and overrides the csharp setting.


int mask (default: 1)
---------------------
0: Processes the entire frame
1: Processes edges only
2: Processes everything except edges

A negative value will show an overlay of the mask.


string mtype (default: "TEMmod")
--------------------------------
The type of edge mask to use. Options are "TEMmod", "TCannyMod", and
mt_edge's "sobel", "roberts", "laplace", "prewitt", "cartoon", and "min/max".
A custom kernel for mt_edge may also be used. See its documentation for more info.

TEMmod's type parameter can be set with a number on the end of the string.
E.g. "TEMmod5" for type=5. If no number is given, the default of 4 is used.
See TEMmod's documentation for explanations of the different types.

This setting also determines the mask type for the eedimthr parameter.


float mthr (default: 8.0)
-------------------------
The threshold of the edge mask. Rounded to the nearest integer for mt_edge types.
When mask=1, lower values result in more edges getting antialiased.
When mask=2, lower values result in fewer edges getting excluded.


int chroma (default: 0)
-----------------------
0: Processes the luma plane only
1: Processes both the luma and chroma planes
2: Processes the chroma planes only


string cplace (default: "MPEG2")
--------------------------------
Specifies the input's chroma placement. Options are "MPEG1" and "MPEG2".
Only applies to formats with subsampled chroma.
Note that only YV12 should be able to have MPEG1 chroma placement.


int nns (default: 1)
--------------------
nnedi3's nns parameter for nnedi3 and nnedi3ocl antialiasing. Ranges from 0 to 4.
Higher values will provide better quality but will be slower.
This setting doesn't affect upscaling with nnedi3 or nnedi3ocl.


float eedimthr (default: 0.0)
-----------------------------
A value greater than 0 creates an edge mask with the given value's threshold
to be used with eedi3 antialiasing and upscaling. Edge-directed interpolation
will be used only on masked edges, increasing eedi3's speed as the threshold is raised,
but at the risk of excluding edges that need antialiasing.


float eediA, float eediB, float eediG (defaults: 0.2, 0.25, 20.0)
-----------------------------------------------------------------
eedi3's alpha, beta, and gamma parameters for eedi3 antialiasing and upscaling.
They adjust the balance between connecting lines and creating artifacts.
eediA and eediB must be in the range 0 to 1 and their sum can't exceed 1.
See eedi3's documentation for more info.


REMOVED: bool lsb_in (default: false)
----------------------------
Set to true if the input is a stacked 16-bit clip.
Because none of the plugins used for antialiasing support 16-bit,
the input will almost always need to be dithered to 8-bit at some point,
but it will be processed in 16-bit where possible.


REMOVED: bool lsb (default: false)
-------------------------
Set to true to output a stacked 16-bit clip.
Because some functions don't support 16-bit, a few 
combinations of settings will result in the lsb being empty.


REMOVED: int threads (default: undefined)
--------------------------------
The number of threads to use for each instance of SangNom2, nnedi3, and eedi3.
Leave this undefined to let the plugins choose automatically.
*/

function Kogarou_xaa(clip input, int "ow", int "oh", float "ss", val "ssw", val "ssh",
\            string "mode", string "uscl", string "dscl", int "csharp", float "cstr",
\            int "mask", string "mtype", float "mthr", int "chroma", string "cplace",
\            int "nns", float "eedimthr", float "eediA", float "eediB", float "eediG")/*,
            bool "lsb_in", bool "lsb", int "threads")*/ {

#lsb_in   = Default(lsb_in, false)
#lsb      = Default(lsb, false)

iw = input.Width()
ih = /*lsb_in ? input.Height()/2 :*/ input.Height()

mode     = Default(mode, "sr SangNom2")
ow       = Default(ow, iw)
oh       = Default(oh, ih)
cplace   = Default(cplace, "MPEG2")
nns      = Default(nns, 1)
eedimthr = Default(eedimthr, 0.0)
eediA    = Default(eediA, 0.2)
eediB    = Default(eediB, 0.25)
eediG    = Default(eediG, 20.0)

# Backwards compatibility with pre-v1.2 mode strings
mode = mode == "SangNom2"       ? "sr SangNom2"
\    : mode == "nnedi3"         ? "sr nnedi3"

\    : mode == "eedi3"          ? "sr eedi3"
\    : mode == "eedi3+nnedi3"   ? "sr eedi3 nnedi3"
\    : mode == "eedi2"          ? "sr eedi2"
\    : mode == "dnnedi3"        ? "drv nnedi3"

\    : mode == "deedi3"         ? "drv eedi3"
\    : mode == "deedi3+dnnedi3" ? "drv eedi3 nnedi3"
\                               : mode

    mode.LeftStr(2) == "dr" ||
\   mode.LeftStr(2) == "di"  ? Eval("""
ss       = Default(ss, 1.0)
ssw      = Default(ssw, ss)
ssh      = Default(ssh, ss)
uscl     = Default(uscl, "Spline36")
dscl     = Default(dscl, "Spline36")
csharp   = Default(csharp, 0)
cstr     = Default(cstr, -1.0)
mask     = Default(mask, 1)
mtype    = Default(mtype, "TEMmod")
mthr     = Default(mthr, 8.0)
chroma   = Default(chroma, 0)
""")
\ : mode == "maa2" ? Eval("""
mode     = "sr SangNom2"
ss       = Default(ss, 2.0)
ssw      = Default(ssw, ss)
ssh      = Default(ssh, ss)
uscl     = Default(uscl, "Spline36")
dscl     = Default(dscl, "Spline36")
csharp   = Default(csharp, 0)
cstr     = Default(cstr, -1.0)
mask     = Default(mask, 1)
mtype    = Default(mtype, "sobel")
mthr     = Default(mthr, 7.0)
chroma   = Default(chroma, 0)
""")
\ : mode == "daa" ? Eval("""
mode     = "drv nnedi3"
ss       = Default(ss, 1.0)
ssw      = Default(ssw, ss)
ssh      = Default(ssh, ss)
uscl     = Default(uscl, "Spline36")
dscl     = Default(dscl, "Spline36")
csharp   = Default(csharp, 1)
cstr     = Default(cstr, -1.0)
mask     = Default(mask, 0)
mtype    = Default(mtype, "TEMmod")
mthr     = Default(mthr, 8.0)
chroma   = Default(chroma, 1)
""")
\ : mode == "Mrdaa"     ||
\   mode == "MrdaaLame"  ? Eval("""
mode     = "null"
ss       = Default(ss, 2.0)
ssw      = Default(ssw, ss)
ssh      = Default(ssh, ss)
uscl     = Default(uscl, "nnedi3")
dscl     = Default(dscl, "Spline36")
csharp   = Default(csharp, 2)
cstr     = Default(cstr, 1.0)
mask     = Default(mask, 0)
mtype    = Default(mtype, "TEMmod")
mthr     = Default(mthr, 8.0)
chroma   = Default(chroma, 1)
""")
\ : mode == "santiag" ? Eval("""
mode     = "di2 nnedi3"
ss       = Default(ss, 1.0)
ssw      = Default(ssw, ss)
ssh      = Default(ssh, ss)
uscl     = Default(uscl, "Spline36")
dscl     = Default(dscl, "Spline36")
csharp   = Default(csharp, 0)
cstr     = Default(cstr, -1.0)
mask     = Default(mask, 0)
mtype    = Default(mtype, "TEMmod")
mthr     = Default(mthr, 8.0)
chroma   = Default(chroma, 1)
""")
\ : Eval("""
ss       = Default(ss, 2.0)
ssw      = Default(ssw, ss)
ssh      = Default(ssh, ss)
uscl     = Default(uscl, "Spline36")
dscl     = Default(dscl, "Spline36")
csharp   = Default(csharp, 0)
cstr     = Default(cstr, -1.0)
mask     = Default(mask, 1)
mtype    = Default(mtype, "TEMmod")
mthr     = Default(mthr, 8.0)
chroma   = Default(chroma, 0)
""")

Assert(ow != 0, "xaa: output width cannot be 0")
Assert(oh != 0, "xaa: output height cannot be 0")
Assert(ss  > 0, "xaa: ss must be greater than 0")
Assert(ssw > 0, "xaa: ssw must be greater than 0")
Assert(ssh > 0, "xaa: ssh must be greater than 0")
Assert(dscl != "nnedi3" && dscl != "nnedi3ocl" && dscl.LeftStr(5) != "eedi3" && dscl != "eedi2",
\      "xaa: "+dscl+" can't be used for downscaling")
Assert(cplace == "MPEG1" || cplace == "MPEG2", "xaa: cplace must be MPEG1 or MPEG2")



##### Set variable values based on parameter settings #####

# Get the input clip's colorspace and make sure it's supported
csp = input.IsY()   ? "Y8"
\   : input.Is420() ? "YV12"
\   : input.Is422() ? "YV16"
\   : input.Is444() ? "YV24"
\                    : Assert(false, "xaa: input must be Y8, YV12, YV16, YUY2, or YV24 (CHANGED: or any of the Y, 420,422, or 444 variants")

# Check for subsampled chroma
hssc12 = input.Is420() || input.Is422() ? true : falsE
vssc12 = input.Is420() ? true : false

Assert(ow < 0 || !hssc12 || ow%2 == 0, "xaa: output width of "+input.PixelType()+" must be a multiple of 2")
Assert(oh < 0 || !vssc12 || oh%2 == 0, "xaa: output height of "+input.PixelType()+" must be a multiple of 2")

# Override the chroma setting if the input is Y8
chroma = input.IsY() ? 0 : chroma
#0=luma ; 1=both ; 2=chroma
# Set chroma values for plugins based on the chroma parameter setting
UVint  = chroma == 0 ? 1 : chroma == 1 || chroma == 2 ? 3 : Assert(false, "xaa: invalid chroma value")
UVint2 = chroma == 0 ? 2 : 3
UVbool = chroma == 0 ? false : true

# YUY2 input has to be converted to YV16 for planar processing and then converted back to YUY2 for output.
#input = csp == "YUY2" ? input.ConvertToYV16() : input

# If ssw or ssh is a float, use it as a multiplier to determine the supersampled resolution
ssw   = ssw.IsInt()   && ssw >  5   ? ssw
\     : ssw.IsFloat() && ssw == 1.0 ? iw
\     : ssw.IsFloat()               ? Int(Round(iw*ssw/4.0)*4)
\                                   : Assert(false, "xaa: ssw value must be a float or int")
ssh   = ssh.IsInt()   && ssh >  5   ? ssh
\     : ssh.IsFloat() && ssh == 1.0 ? ih
\     : ssh.IsFloat()               ? Int(Round(ih*ssh/4.0)*4)
\                                   : Assert(false, "xaa: ssh value must be a float or int")

# Output at the supersampled resolution if the output width or height is negative
    ow < 0 || oh < 0 ?
\   Eval("""
         ow = ssw
         oh = ssh
         """)
\ : NOP()

# Get the aa mode from the mode string
aa_mode = mode == "null"           ? "null"
\       : mode.LeftStr(2) == "sr" ||
\         mode.LeftStr(2) == "dr" ||
\         mode.LeftStr(2) == "di"  ? mode.LeftStr(2)
\                                  : Assert(false, "xaa: invalid mode string")
mode = mode != "null" ? mode.RightStr(mode.StrLen()-2) : mode

# Remove spacers from the mode string
mode = mode.LeftStr(1) == " " ||
\      mode.LeftStr(1) == "_" ||
\      mode.LeftStr(1) == "+" ||
\      mode.LeftStr(1) == "-"  ? mode.RightStr(mode.StrLen()-1)
\                              : mode

# Get the aa direction from the mode string
    mode.LeftStr(1) == "b" ?
\   Eval("""
         aa_h = true
         aa_v = true
         mode = mode.RightStr(mode.StrLen()-1)
         """)
\ : mode.LeftStr(1) == "h" ?
\   Eval("""
         aa_h = true
         aa_v = false
         mode = mode.RightStr(mode.StrLen()-1)
         """)
\ : mode.LeftStr(1) == "v" ?
\   Eval("""
         aa_h = false
         aa_v = true
         mode = mode.RightStr(mode.StrLen()-1)
         """)
\ : Eval("""
         aa_h = true
         aa_v = true
         """)

mode = mode.LeftStr(1) == " " ||
\      mode.LeftStr(1) == "_" ||
\      mode.LeftStr(1) == "+" ||
\      mode.LeftStr(1) == "-"  ? mode.RightStr(mode.StrLen()-1)
\                              : mode

# Get the number of aa passes from the mode string
Assert(mode.LeftStr(1) != "0", "xaa: number of aa passes must be > 0")
    mode.LeftStr(1).Value() > 0 ?
\   Eval("""
         aa_pass = mode.LeftStr(1).Value().Int()
         mode    = mode.RightStr(mode.StrLen()-1)
         """)
\ : Eval("""
         aa_pass = 1
         """)

mode = mode.LeftStr(1) == " " ||
\      mode.LeftStr(1) == "_" ||
\      mode.LeftStr(1) == "+" ||
\      mode.LeftStr(1) == "-"  ? mode.RightStr(mode.StrLen()-1)
\                              : mode

# Get the aa type from the mode string
aa_type = mode == "null"                  ? "null"
\       : mode.LeftStr(8) == "SangNom2"   ? "SangNom2"
\       : mode.LeftStr(6) == "nnedi3"    ? "nnedi3"
\       : mode.LeftStr(5) == "eedi3"      ? "eedi3"
\       : mode.LeftStr(5) == "eedi2"      ? "eedi2"
\                                         : Assert(false, "xaa: invalid mode string")

# Get the aa sclip from the mode string
mode = aa_type == "eedi3" && mode.StrLen() > 5 ? mode.RightStr(mode.StrLen()-5) : ""
mode = mode.LeftStr(1) == " " ||
\      mode.LeftStr(1) == "_" ||
\      mode.LeftStr(1) == "+" ||
\      mode.LeftStr(1) == "-"  ? mode.RightStr(mode.StrLen()-1)
\                              : mode
aa_sclip = mode

#FIXME: i am not entirely sure about the others, everything should support HBD but for now i only want NNEDI3
# These aa types can process Y8, YV16, and YV24 while others require conversion to YV12
Yx_aa_type = aa_type == "SangNom2"  || 
\            aa_type == "nnedi3"      ? true : false

# Get the sclip setting for eedi3 upscaling from the uscl string
    uscl.LeftStr(5) == "eedi3" && uscl.StrLen() > 5 ?
\   Eval("""
         rs_sclip = uscl.RightStr(uscl.StrLen()-5)
         uscl     = "eedi3"
         """)
\ : Eval("""
         rs_sclip = ""
         """)
rs_sclip = rs_sclip.LeftStr(1) == " " ||
\          rs_sclip.LeftStr(1) == "_" ||
\          rs_sclip.LeftStr(1) == "+" ||
\          rs_sclip.LeftStr(1) == "-"  ? rs_sclip.RightStr(rs_sclip.StrLen()-1)
\                                      : rs_sclip

# Define these before the resize sections so they can be used as conditionals
aa_ow = aa_mode == "di" && csharp != 1 && !aa_v ? ssw*2 : ssw
aa_oh = aa_mode == "di" && csharp != 1 &&  aa_v ? ssh*2 : ssh

rs1_type   = ssw > iw || ssh > ih ? uscl : dscl
rs1_isedi  = rs1_type == "nnedi3" || /*rs1_type == "nnedi3ocl" ||*/
\            rs1_type == "eedi3"  || rs1_type == "eedi2"      ? true : false
rsaa_type  = ow > aa_ow || oh > aa_oh ? uscl : dscl
rsaa_isedi = rsaa_type == "nnedi3" || /*rsaa_type == "nnedi3ocl" ||*/
\            rsaa_type == "eedi3"  || rsaa_type == "eedi2"      ? true : false
rs2_type   = ow > iw || oh > ih ? uscl : dscl
rs2_isedi  = rs2_type == "nnedi3" || /*rs2_type == "nnedi3ocl" ||*/
\            rs2_type == "eedi3"  || rs2_type == "eedi2"      ? true : false

# Override the csharp setting if cstr=0, or if csharp=1 and mode="null" since it won't have any effect in that case.
# Override the cstr setting if csharp=0 since it won't be used.
csharp = cstr == 0 || csharp == 1 && aa_mode == "null" ? 0 : csharp
cstr   = csharp == 0 ? 0 : cstr

# Get TEMmod's type parameter from the mtype string if present, or otherwise default to type 4
Assert(mtype.LeftStr(6) != "TEMmod" || mtype.LeftStr(6) == "TEMmod" && mtype.StrLen() <= 7, "xaa: invalid TEMmod type")

    mtype.LeftStr(6) == "TEMmod" && mtype.StrLen() > 6 ?
\   Eval("""
         temtype = mtype.RightStr(1).Value().Int()
         mtype = "TEMmod"
         Assert(temtype > 0 && temtype < 6, "xaa: invalid TEMmod type")
         """)
\ : Eval("""
         temtype = 4
         """)

# Round the mthr values for mt_edge mask types
mthr     = mtype != "TEMmod" && mtype != "TCannyMod" ? mthr.Round() : mthr
eedimthr = mtype != "TEMmod" && mtype != "TCannyMod" ? eedimthr.Round() : eedimthr



##### Scale the input clip to the supersampled resolution #####
#rip stack lmao
/*stack16i = lsb_in ? true : false
stack16o = stack16i && aa_mode == "null" && csharp == 0 && !rsaa_isedi              ||
\          stack16i && aa_mode == "null" && cstr   <= 0 && !rsaa_isedi              ||
\          lsb      && aa_mode == "null" && cstr   <= 0 && !rsaa_isedi              ||
\          lsb      && aa_mode == "di"   && csharp == 1 && cstr <= 0 && !rsaa_isedi ||
\          lsb      && aa_mode == "di"   && csharp == 1 && cstr <= 0 && !rsaa_isedi  ? true : false*/

# rs1_type and rs1_isedi are defined earlier
rs1_rfacX  = ssw > iw*6-4 ? 8
\          : ssw > iw*3-4 ? 4
\          : ssw > iw     ? 2
\                         : 1
rs1_rfacY  = ssh > ih*6-4 ? 8
\          : ssh > ih*3-4 ? 4
\          : ssh > ih     ? 2
\                         : 1
rs1_cshift = ssw >= iw*rs1_rfacX || ssh >= ih*rs1_rfacY ? "Spline36" : dscl

# To avoid resizing twice, don't correct the edi_rpow2 center shift until
# resizing to the output resolution if no other processing will happen until then.
# This isn't done all the time because the center shift messes with antialiasing.
delay_cshift = aa_mode == "null" && rs1_isedi && ssw == iw*rs1_rfacX && ssh == ih*rs1_rfacY ? true : false
rs1_hshift   = !hssc12 || chroma == 0 ? -0.5 : -0.5*(rs1_rfacX-1)
rs1_hshift   = delay_cshift && rs1_isedi && rs1_rfacX > 1  ? rs1_hshift : 0
rs1_vshift   = delay_cshift && rs1_isedi && rs1_rfacY > 1  ? -0.5 : 0
rs1_hshift_c = delay_cshift && rs1_isedi && rs1_rfacX > 1 && cplace == "MPEG1" && hssc12 && UVbool ? -0.5*(rs1_rfacX-1)+rs1_hshift : rs1_hshift
rs1_vshift_c = delay_cshift && rs1_isedi && rs1_rfacY > 1 && vssc12 && UVbool ? rs1_vshift*2.0 : rs1_vshift

input_8bit = /*stack16i ? input.DitherPost(mode=-1) :*/ input #yeah this isnt needed anymore, it should be bit agnostic

# Edge mask for eedi3's mclip parameter to use for the rs1 and rs2 resizes
    uscl == "eedi3" && eedimthr > 0 ?
\   Eval("""
         rs12_mclip = mtype == "TEMmod"    ? input_8bit.vsTEdgeMask(eedimthr, eedimthr, eedimthr, temtype, 0, U=UVint2,V=UVint2)
         \                                             .mt_inflate(U=UVint, V=UVint)
         \          : mtype == "TCannyMod" ? input_8bit.TCannyMod(t_h=eedimthr, t_l=eedimthr, U=UVint2,V=UVint2)
         \                                             .mt_expand(mode="both", U=UVint, V=UVint).mt_inflate(U=UVint, V=UVint)
         \                                             .mt_inpand(mode="both", U=UVint, V=UVint).mt_inflate(U=UVint, V=UVint)
         \                                 : input_8bit.mt_edge(mtype,eedimthr,eedimthr,eedimthr,eedimthr, U=UVint, V=UVint)
         \                                             .mt_inflate(U=UVint, V=UVint)
         """)
\ : Eval("""
         rs12_mclip = Undefined()
         """)

input_y8 = chroma == 0 ? input.ConvertToY() : input

    ssw == iw && ssh == ih ?
\   Eval("""
         rs1 = input_y8
         """)
\ : rs1_isedi ?
\   Eval("""
         rs1 = input_y8
         rs1 = delay_cshift ? rs1.edi_rpow2(rs1_rfacX,rs1_rfacY,rs1_type, cplace=cplace, YV12cfix=false,
         \                                  alpha=eediA, beta=eediB, gamma=eediG, sclip=rs_sclip, mclip=rs12_mclip)
         \                  : rs1.edi_rpow2(rs1_rfacX,rs1_rfacY,rs1_type,rs1_cshift,ssw,ssh, cplace=cplace,
         \                                  alpha=eediA, beta=eediB, gamma=eediG, sclip=rs_sclip, mclip=rs12_mclip)
         """)
\ : Eval("""
         rs1 = input_y8.ResizeX(ssw,ssh, kernel=rs1_type, cplace=cplace)
         """)

rs1_8bit = rs1



##### Apply antialiasing to the supersampled clip #####

/*stack16i = stack16o ? true : false
stack16o = stack16i && aa_mode == "null"                                            ||
\          lsb      && aa_mode == "di"   && csharp == 1 && cstr <= 0 && !rsaa_isedi ||
\          lsb      && aa_mode == "di"   && csharp == 1 && cstr <= 0 && !rsaa_isedi  ? true : false*/

# Don't output in stack16 after antialiasing horizontally
# if the clip is going to be antialiased vertically afterward.
#stack16o_h = stack16o && !aa_v ? true : false

# To avoid resizing twice, don't downscale the aaclip after di antialiasing unless needed for csharp=1.
aa_delayresize_h = aa_mode == "di" && csharp != 1 && !aa_v ? true : false
aa_delayresize_v = aa_mode == "di" && csharp != 1 &&  aa_v ? true : false
aa_hshift        = aa_delayresize_h ? -0.5 : 0
aa_vshift        = aa_delayresize_v ? -0.5 : 0
aa_hshift_c      = aa_delayresize_h && hssc12 && UVbool && cplace == "MPEG1" ? -0.5+aa_hshift : aa_hshift
aa_vshift_c      = aa_delayresize_v && vssc12 && UVbool ? aa_vshift*2.0 : aa_vshift

# Pad the frame with rows of duplicate pixels to avoid errors from
# mod1 resolutions and edge distortion caused by deinterlacing.
rs1_ismod4 = ssw%4 == 0 && ssh%4 == 0 ? true : false
rs1_ismod8 = ssw%8 == 0 && ssh%8 == 0 ? true : false
rs1_pad8   = !rs1_ismod8 && aa_type == "eedi2" && hssc12 && csp != "YV12" && UVbool ||
\            !rs1_ismod8 && aa_type == "eedi3" && hssc12 && csp != "YV12" && UVbool &&
\            aa_sclip != "" && aa_sclip != "SangNom2" && aa_sclip != "nnedi3"  ? true : false

# Don't add padding when using di eedi3 antialiasing unless it's
# needed for mod4/mod8 compatibility because it doesn't distort edges.
rs1_addpad = aa_mode == "null" || aa_mode == "di" && aa_type == "eedi3" && rs1_ismod4 && !rs1_pad8 ? false : true

rs1_padR = rs1_pad8 ? 8-ssw%8 : 4-ssw%4
rs1_padT = rs1_pad8 ? 8-ssh%8 : 4-ssh%4

rs1_padR = rs1_padR >= 4 ? rs1_padR
\                        : rs1_padR+4
rs1_padT = rs1_padT >= 4 ? rs1_padT
\                        : rs1_padT+4
rs1_padL = rs1_pad8 && (ssw+rs1_padR+4)%8 == 0 ? 4
\        : rs1_pad8                            ? 8
\                                              : 4
rs1_padB = rs1_pad8 && (ssh+rs1_padT+4)%8 == 0 ? 4
\        : rs1_pad8                            ? 8
\                                              : 4

ssw_pad   = rs1_addpad ? ssw+rs1_padR+rs1_padL : ssw
ssh_pad   = rs1_addpad ? ssh+rs1_padT+rs1_padB : ssh
ssw_pad_c = hssc12 ? ssw_pad/2 : ssw_pad
ssh_pad_c = vssc12 ? ssh_pad/2 : ssh_pad

# Edge mask for eedi3's mclip parameter to use for antialiasing
    eedimthr > 0 ?
\   Eval("""
         aa_mclip = mtype == "TEMmod"    ? rs1_8bit.vsTEdgeMask(eedimthr,eedimthr,eedimthr,temtype,0, U=UVint2,V=UVint2)
         \                                         .mt_inflate(U=UVint, V=UVint)
         \        : mtype == "TCannyMod" ? rs1_8bit.vsTCanny(t_h=eedimthr, t_l=eedimthr, U=UVint2,V=UVint2)
         \                                         .mt_expand(mode="both", U=UVint, V=UVint).mt_inflate(U=UVint, V=UVint)
         \                                         .mt_inpand(mode="both", U=UVint, V=UVint).mt_inflate(U=UVint, V=UVint)
         \                               : rs1_8bit.mt_edge(mtype,eedimthr,eedimthr,eedimthr,eedimthr, U=UVint, V=UVint)
         \                                         .mt_inflate(U=UVint, V=UVint)
         
         aa_mclip_pad  = rs1_addpad ? aa_mclip.ResizeX(ssw+rs1_padL+rs1_padR, ssh+rs1_padT+rs1_padB, -rs1_padL, -rs1_padT,
\                                                      ssw+rs1_padL+rs1_padR, ssh+rs1_padT+rs1_padB, kernel="Point", chroma=UVbool)
\                                   : aa_mclip
         aa_mclipv     = aa_mclip_pad.ConvertToYV12()
         aa_mcliph     = aa_mclipv.TurnRight()
         aa_mclipvU    = UVbool ? aa_mclip_pad.UToY8().ConvertToYV12() : Undefined()
         aa_mcliphU    = UVbool ? aa_mclipvU.TurnRight() : Undefined()
         aa_mclipvV    = UVbool ? aa_mclip_pad.VToY8().ConvertToYV12() : Undefined()
         aa_mcliphV    = UVbool ? aa_mclipvV.TurnRight() : Undefined()
         """)
\ : Eval("""
         aa_mclip   = Undefined()
         aa_mclipv  = Undefined()
         aa_mcliph  = Undefined()
         aa_mclipvU = Undefined()
         aa_mcliphU = Undefined()
         aa_mclipvV = Undefined()
         aa_mcliphV = Undefined()
         """)

rs1_pad = rs1_addpad ? rs1_8bit.ResizeX(ssw+rs1_padL+rs1_padR, ssh+rs1_padT+rs1_padB, -rs1_padL, -rs1_padT,
\                                       ssw+rs1_padL+rs1_padR, ssh+rs1_padT+rs1_padB, kernel="Point", chroma=UVbool)
\                    : rs1_8bit

# Perform antialiasing
    aa_mode == "null" ?
\   Eval("""
         aaclip  = rs1
         """)
\ : Yx_aa_type && aa_type != "SangNom2" && csp != "YV16" ||
\   aa_type != "SangNom2" && csp == "YV12" && UVbool                       ?
\   Eval("""
         # When using SangNom2, it's faster to split the planes into Y8 clips and process them separately
         aaclip  = aa_h ? rs1_pad.TurnRight() : rs1_pad
         aaclip  = aa_h && aa_mode == "sr" ? aaclip.xaa_sr(aa_type,aa_pass,UVbool,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \       : aa_h && aa_mode == "dr" ? aaclip.xaa_dr(aa_type,aa_pass,UVbool,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \       : aa_h && aa_mode == "di" ? aaclip.xaa_di(aa_type,aa_pass,UVbool,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \                                 : aaclip
         aaclip  =  aa_h && aa_mode == "di" &&
         \         !aa_delayresize_h        &&
         \          vssc12 && UVbool         ? aaclip.ResizeX(ssh_pad,ssw_pad,0,-0.5, kernel=dscl, chroma=false)
         \                                           .MergeChroma(aaclip.ResizeX(ssh_pad,ssw_pad,0,-1.0, kernel=dscl, cplace=cplace, luma=false))
         \       :  aa_h && aa_mode == "di" &&
         \         !aa_delayresize_h         ? aaclip.ResizeX(ssh_pad,ssw_pad,0,-0.5, kernel=dscl, cplace=cplace, chroma=UVbool)
         \                                   : aaclip
         aaclip  = aa_h               ? aaclip.TurnLeft()
         \                            : aaclip
         aaclip  = aa_v && aa_mode == "sr" ? aaclip.xaa_sr(aa_type,aa_pass,UVbool,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \       : aa_v && aa_mode == "dr" ? aaclip.xaa_dr(aa_type,aa_pass,UVbool,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \       : aa_v && aa_mode == "di" ? aaclip.xaa_di(aa_type,aa_pass,UVbool,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \                                 : aaclip
         aaclip  =  aa_v && aa_mode == "di" &&
         \         !aa_delayresize_v        &&
         \          vssc12 && UVbool         ? aaclip.ResizeX(ssw_pad,ssh_pad,0,-0.5, kernel=dscl, chroma=false)
         \                                           .MergeChroma(aaclip.ResizeX(ssw_pad,ssh_pad,0,-1.0, kernel=dscl, cplace=cplace, luma=false))
         \       :  aa_v && aa_mode == "di" &&
         \         !aa_delayresize_v         ? aaclip.ResizeX(ssw_pad,ssh_pad,0,-0.5, kernel=dscl, cplace=cplace, chroma=UVbool)
         \                                   : aaclip
         """)
\ : !UVbool ?
\   Eval("""
         aaclip  = aa_h && Yx_aa_type ? rs1_pad.TurnRight()
         \       : aa_h               ? rs1_pad.TurnRight().ConvertToYUV420()
         \       :         Yx_aa_type ? rs1_pad
         \                            : rs1_pad.ConvertToYUV420()
         aaclip  = aa_h && aa_mode == "sr" ? aaclip.xaa_sr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \       : aa_h && aa_mode == "dr" ? aaclip.xaa_dr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \       : aa_h && aa_mode == "di" ? aaclip.xaa_di(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \                                 : aaclip
         aaclip  =  aa_h && aa_mode == "di" &&
         \         !aa_delayresize_h         ? aaclip.ResizeX(ssh_pad,ssw_pad,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclip
         aaclip  = aa_h               ? aaclip.TurnLeft()
         \                            : aaclip
         aaclip  = aa_v && aa_mode == "sr" ? aaclip.xaa_sr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \       : aa_v && aa_mode == "dr" ? aaclip.xaa_dr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \       : aa_v && aa_mode == "di" ? aaclip.xaa_di(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \                                 : aaclip
         aaclip  =  aa_v && aa_mode == "di" &&
         \         !aa_delayresize_v         ? aaclip.ResizeX(ssw_pad,ssh_pad,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclip
         aaclip  = aaclip.ConvertToY()
         """)
\ : Eval("""
         aaclipY = aa_h && Yx_aa_type ? rs1_pad.ConvertToY().TurnRight()
         \       : aa_h               ? rs1_pad.TurnRight().ConvertToYUV420()
         \       :         Yx_aa_type ? rs1_pad.ConvertToY()
         \                            : rs1_pad.ConvertToYUV420()
         aaclipY = aa_h && aa_mode == "sr" ? aaclipY.xaa_sr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \       : aa_h && aa_mode == "dr" ? aaclipY.xaa_dr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \       : aa_h && aa_mode == "di" ? aaclipY.xaa_di(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mcliph)
         \                                 : aaclipY
         aaclipY =  aa_h && aa_mode == "di" &&
         \         !aa_delayresize_h         ? aaclipY.ResizeX(ssh_pad,ssw_pad,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclipY
         aaclipY = aa_h               ? aaclipY.TurnLeft()
         \                            : aaclipY
         aaclipY = aa_v && aa_mode == "sr" ? aaclipY.xaa_sr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \       : aa_v && aa_mode == "dr" ? aaclipY.xaa_dr(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \       : aa_v && aa_mode == "di" ? aaclipY.xaa_di(aa_type,aa_pass,false,cplace,48,nns,eediA,eediB,eediG,aa_sclip,aa_mclipv)
         \                                 : aaclipY
         aaclipY =  aa_v && aa_mode == "di" &&
         \         !aa_delayresize_v         ? aaclipY.ResizeX(ssw_pad,ssh_pad,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclipY
         
         aaclipU = aa_h && Yx_aa_type ? rs1_pad.ExtractU().TurnRight()
         \       : aa_h               ? rs1_pad.ExtractU().TurnRight().ConvertToYUV420()
         \       :         Yx_aa_type ? rs1_pad.ExtractU()
         \                            : rs1_pad.ExtractU().ConvertToYUV420()
         aaclipU = aa_h && aa_mode == "sr" ? aaclipU.xaa_sr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mcliphU)
         \       : aa_h && aa_mode == "dr" ? aaclipU.xaa_dr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mcliphU)
         \       : aa_h && aa_mode == "di" ? aaclipU.xaa_di(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mcliphU)
         \                                 : aaclipU
         aaclipU =  aa_h && aa_mode == "di" &&
         \         !aa_delayresize_h         ? aaclipU.ResizeX(ssh_pad_c,ssw_pad_c,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclipU
         aaclipU = aa_h               ? aaclipU.TurnLeft()
         \                            : aaclipU
         aaclipU = aa_v && aa_mode == "sr" ? aaclipU.xaa_sr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mclipvU)
         \       : aa_v && aa_mode == "dr" ? aaclipU.xaa_dr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mclipvU)
         \       : aa_v && aa_mode == "di" ? aaclipU.xaa_di(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mclipvU)
         \                                 : aaclipU
         aaclipU =  aa_v && aa_mode == "di" &&
         \         !aa_delayresize_v         ? aaclipU.ResizeX(ssw_pad_c,ssh_pad_c,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclipU
         #
         aaclipV = aa_h && Yx_aa_type ? rs1_pad.ExtractV().TurnRight()
         \       : aa_h               ? rs1_pad.ExtractV().TurnRight().ConvertToYUV420()
         \       :         Yx_aa_type ? rs1_pad.ExtractV()
         \                            : rs1_pad.ExtractV().ConvertToYUV420()
         aaclipV = aa_h && aa_mode == "sr" ? aaclipV.xaa_sr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mcliphV)
         \       : aa_h && aa_mode == "dr" ? aaclipV.xaa_dr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mcliphV)
         \       : aa_h && aa_mode == "di" ? aaclipV.xaa_di(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mcliphV)
         \                                 : aaclipV
         aaclipV =  aa_h && aa_mode == "di" &&
         \         !aa_delayresize_h         ? aaclipV.ResizeX(ssh_pad_c,ssw_pad_c,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclipV
         aaclipV = aa_h               ? aaclipV.TurnLeft()
         \                            : aaclipV
         aaclipV = aa_v && aa_mode == "sr" ? aaclipV.xaa_sr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mclipvV)
         \       : aa_v && aa_mode == "dr" ? aaclipV.xaa_dr(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mclipvV)
         \       : aa_v && aa_mode == "di" ? aaclipV.xaa_di(aa_type,aa_pass,false,cplace,0,nns,eediA,eediB,eediG,aa_sclip,aa_mclipvV)
         \                                 : aaclipV
         aaclipV =  aa_v && aa_mode == "di" &&
         \         !aa_delayresize_v         ? aaclipV.ResizeX(ssw_pad_c,ssh_pad_c,0,-0.5, kernel=dscl, chroma=false)
         \                                   : aaclipV
         aaclip  = CombinePlanes(aaclipY.ExtractY(),aaclipU.ExtractY(),aaclipV.ExtractY(), planes="YUV", source_planes="YYY")/*YToUV(aaclipU,aaclipV,aaclipY)*/
         """)

# Crop the padding off
aaclip = rs1_addpad && aa_delayresize_h               ? aaclip.Crop(rs1_padL*2,rs1_padT,-rs1_padR*2,-rs1_padB)
\      : rs1_addpad && aa_delayresize_v               ? aaclip.Crop(rs1_padL,rs1_padT*2,-rs1_padR,-rs1_padB*2)
\      : rs1_addpad                                   ? aaclip.Crop(rs1_padL,rs1_padT,-rs1_padR,-rs1_padB)
\                                                     : aaclip



##### Apply contra-sharpening before scaling to the output resolution if csharp=1 #####

#stack16i = stack16o ? true : false
#stack16o = stack16i ? true : false

UVrg = chroma == 0 ? -1 : 11
UVrp = chroma == 0 ? -1 : 13

    csharp == 0 || csharp == 2 ? NOP()
\ : csharp == 1 ?
\   Eval("""
         aadiff    = mt_makediff(rs1, aaclip, U=UVint, V=UVint)
         aablur    = aaclip.RemoveGrain(mode=11, modeU=UVrg, modeV=UVrg)
         sharpdiff = mt_makediff(aaclip, aablur, U=UVint, V=UVint)
         repaired  = sharpdiff.Repair(aadiff, mode=13, modeU=UVrp, modeV=UVrp)
         aaclip    = aaclip.mt_adddiff(repaired, U=UVint, V=UVint)
         """)
\ : Assert(false, "xaa: invalid csharp value")

##### Scale the antialiased clip to the output resolution #####

#stack16i = stack16o ? true : false
#stack16o = lsb && csharp != 2 ||
#\          lsb && cstr   <= 0  ? true : false

# rsaa_type and rsaa_isedi are defined earlier
rsaa_rfacX  = ow > aa_ow*6-4 ? 8
\           : ow > aa_ow*3-4 ? 4
\           : ow > aa_ow     ? 2
\                            : 1
rsaa_rfacY  = oh > aa_oh*6-4 ? 8
\           : oh > aa_oh*3-4 ? 4
\           : oh > aa_oh     ? 2
\                            : 1
rsaa_cshift = ow >= aa_ow*rsaa_rfacX || oh >= aa_oh*rsaa_rfacY ? "Spline36" : dscl

# Center shift values for the rsaa resize if edi_rpow2 is used
rsaa_hshift   = !hssc12 || chroma == 0 ? -0.5 : -0.5*(rsaa_rfacX-1)
rsaa_hshift   = rsaa_isedi && rsaa_rfacX > 1 ? rsaa_hshift : 0
rsaa_vshift   = rsaa_isedi && rsaa_rfacY > 1 ? -0.5 : 0
rsaa_hshift_c = rsaa_isedi && rsaa_rfacX > 1 && cplace == "MPEG1" && hssc12 && UVbool ? -0.5*(rsaa_rfacX-1)+rsaa_hshift : rsaa_hshift
rsaa_vshift_c = rsaa_isedi && rsaa_rfacY > 1 && vssc12 && UVbool ? rsaa_vshift*2.0 : rsaa_vshift

# Add center shift corrections from rs1 delay_cshift and aa_delayresize to the rsaa corrections
rsaa_hshift   = rsaa_isedi ? rsaa_hshift+rs1_hshift*rsaa_rfacX+aa_hshift*rsaa_rfacX
\                          : rs1_hshift+aa_hshift
rsaa_vshift   = rsaa_isedi ? rsaa_vshift+rs1_vshift*rsaa_rfacY+aa_vshift*rsaa_rfacY
\                          : rs1_vshift+aa_vshift
rsaa_hshift_c = rsaa_isedi ? rsaa_hshift_c+rs1_hshift_c*rsaa_rfacX+aa_hshift_c*rsaa_rfacX
\                          : rs1_hshift_c+aa_hshift_c
rsaa_vshift_c = rsaa_isedi ? rsaa_vshift_c+rs1_vshift_c*rsaa_rfacY+aa_vshift_c*rsaa_rfacY
\                          : rs1_vshift_c+aa_vshift_c
rsaa_UVshift  = rsaa_hshift != rsaa_hshift_c || rsaa_vshift != rsaa_vshift_c ? true : false

# Reuse the eedi3 mclip mask from antialiasing
rsaa_mclip = uscl == "eedi3" && eedimthr > 0 ? aa_mclip : Undefined()

aaclip_y8 = chroma == 0 ? aaclip.ConvertToY() : aaclip

    ow == aa_ow   && oh == aa_oh       &&
\   !delay_cshift && !aa_delayresize_h && !aa_delayresize_v ?
\   Eval("""
         rsaa =  aaclip_y8
         """)
\ : rsaa_isedi && delay_cshift     ||
\   rsaa_isedi && aa_delayresize_h ||
\   rsaa_isedi && aa_delayresize_v  ?
\   Eval("""
         # Use stack16o for ResizeX's lsb_in parameter here because it depends on edi_rpow2's lsb parameter, not stack16i.
         rsaa =  aaclip_y8
         rsaa = rsaa.edi_rpow2(rsaa_rfacX,rsaa_rfacY,rsaa_type, cplace=cplace, YV12cfix=false,
         \                     alpha=eediA, beta=eediB, gamma=eediG, sclip=rs_sclip, mclip=rsaa_mclip)
         rsaa = rsaa_UVshift ? rsaa.ResizeX(ow,oh,rsaa_hshift,rsaa_vshift, kernel=rsaa_cshift, chroma=false)
         \                         .MergeChroma(rsaa.ResizeX(ow,oh,rsaa_hshift_c,rsaa_vshift_c, kernel=rsaa_cshift, cplace=cplace, luma=false))
         \                   : rsaa.ResizeX(ow,oh,rsaa_hshift,rsaa_vshift, kernel=rsaa_cshift, cplace=cplace)
         """)
\ : rsaa_isedi ?
\   Eval("""
         rsaa = aaclip_y8
         rsaa = rsaa.edi_rpow2(rsaa_rfacX,rsaa_rfacY,rsaa_type,rsaa_cshift,ow,oh, cplace=cplace,
         \                     alpha=eediA, beta=eediB, gamma=eediG, sclip=rs_sclip, mclip=rsaa_mclip)
         """)
\ : Eval("""
         rsaa = rsaa_UVshift ? aaclip_y8.ResizeX(ow,oh,rsaa_hshift,rsaa_vshift, kernel=rsaa_cshift, chroma=false)
         \                              .MergeChroma(aaclip_y8.ResizeX(ow,oh,rsaa_hshift_c,rsaa_vshift_c, kernel=rsaa_cshift, cplace=cplace, luma=false))
         \                   : aaclip_y8.ResizeX(ow,oh,rsaa_hshift,rsaa_vshift, kernel=rsaa_cshift, cplace=cplace)
         """)

# Make sure the rsaa clip has the same chroma sampling as the input
rsaa = csp == "Y8"    ? rsaa.ConvertToY()
\    : csp == "YV12"  ? rsaa.ConvertToYUV420()
\    : csp == "YV16"  ? rsaa.ConvertToYUV422()
\    : csp == "YV24"  ? rsaa.ConvertToYUV444()
\                     : Assert(false, "xaa: something went terribly wrong")



##### Scale the input clip to the output resolution without antialiasing for masking and chroma #####

/*stack16i2 = lsb_in ? true : false
stack16o2 = lsb && csharp != 2 ||
\           lsb && cstr   <= 0 ||
\           lsb && csharp == 2 && mask > 0 ? true : false*/

# rs2_type and rs2_isedi are defined earlier
rs2_rfacX  = ow > iw*6-4 ? 8
\          : ow > iw*3-4 ? 4
\          : ow > iw     ? 2
\                        : 1
rs2_rfacY  = oh > ih*6-4 ? 8
\          : oh > ih*3-4 ? 4
\          : oh > ih     ? 2
\                        : 1
rs2_cshift = ow >= iw*rs2_rfacX && oh >= ih*rs2_rfacY ? "Spline36" : dscl

    ow == iw && oh == ih ?
\   Eval("""
         rs2 = input
         """)
\ : rs2_isedi ?
\   Eval("""
         rs2 =  input
         rs2 = rs2.edi_rpow2(rs2_rfacX,rs1_rfacY,rs2_type,rs2_cshift,ow,oh, cplace=cplace,
         \                   alpha=eediA, beta=eediB, gamma=eediG, sclip=rs_sclip, mclip=rs12_mclip)
         """)
\ : Eval("""
         rs2 = input.ResizeX(ow,oh, kernel=rs2_type, cplace=cplace)
         """)

# 8-bit versions of the rs2 clip for masking
rs2_8bit      = rs2
rs2_8bit_yv24 = rs2_8bit.ConvertToYUV420()



##### Apply contra-sharpening after scaling to the output resolution if csharp=2 #####

    csharp == 0 || csharp == 1 ? NOP()
\ : csharp == 2 ?
\   Eval("""
         aadiff    = mt_makediff(rs2, rsaa, U=UVint, V=UVint)
         aablur    = rsaa.removegrain(mode=11, modeU=UVrg, modeV=UVrg)
         sharpdiff = mt_makediff(rsaa, aablur, U=UVint, V=UVint)
         repaired  = sharpdiff.repair(aadiff, mode=13, modeU=UVrp, modeV=UVrp)
         rsaa      = rsaa.mt_adddiff(repaired, U=UVint, V=UVint)
         """)
\ : Assert(false, "xaa: invalid csharp value")



##### Masking, chroma merging, and output #####

#stack16i = stack16o || stack16o2 ? true : false
#stack16o = lsb ? true : false

# Reuse the eedi3 mclip mask from the rs1 and rs2 resizes if it's the same
emask = rs12_mclip.Defined() && mthr == eedimthr && iw == ow && ih == oh ? rs12_mclip
\     : mtype == "TEMmod"    ? rs2_8bit.vsTEdgeMask(mthr,mthr,mthr,temtype,0,U=UVint2,V=UVint2).mt_inflate(U=UVint, V=UVint)
\     : mtype == "TCannyMod" ? rs2_8bit.vsTCanny(t_h=mthr, t_l=mthr, U=UVint2,V=UVint2).mt_expand(mode="both", U=UVint, V=UVint)
\                                      .mt_inflate(U=UVint, V=UVint).mt_inpand(mode="both", U=UVint, V=UVint).mt_inflate(U=UVint, V=UVint)
\                            : rs2_8bit.mt_edge(mtype,mthr,mthr,mthr,mthr, U=UVint, V=UVint).mt_inflate(U=UVint, V=UVint)

eover   = csp == "Y8"   ||
\         csp == "YV16" ? rs2_8bit_yv24.mt_lut("x 2 /",Y=2,U=3,V=3)
\                        : rs2_8bit.mt_lut("x 2 /",Y=2,U=3,V=3)
overlay = csp == "Y8"   ||
\         csp == "YV16" ? mt_merge(rs2_8bit_yv24,eover,emask, luma=true)
\                        : mt_merge(rs2_8bit,eover,emask, luma=true)
overlay = csp == "YV16" ? overlay.ConvertToYUV422()
\                        : overlay

Eval("""
merged = mask == 0 && csp == "Y8" ? rsaa
\      : mask == 0 && chroma == 0 ? MergeChroma(rsaa,rs2)
\      : mask == 0 && chroma == 1 ? rsaa
\      : mask == 0 && chroma == 2 ? MergeChroma(rs2,rsaa)
\      : mask == 1 && chroma == 0 ? mt_merge(rs2,rsaa,emask,Y=3,U=2,V=2)
\      : mask == 1 && chroma == 1 ? mt_merge(rs2,rsaa,emask,Y=3,U=3,V=3)
\      : mask == 1 && chroma == 2 ? mt_merge(rs2,rsaa,emask,Y=2,U=3,V=3)
\      : mask == 2 && chroma == 0 ? mt_merge(rsaa,rs2,emask,Y=3,U=4,V=4)
\      : mask == 2 && chroma == 1 ? mt_merge(rsaa,rs2,emask,Y=3,U=3,V=3)
\      : mask == 2 && chroma == 2 ? mt_merge(rsaa,rs2,emask,Y=4,U=3,V=3)
\                                 : Assert(mask <= 2, "xaa: invalid mask value")
""")

output = mask < 0 ? overlay : merged

return output
}



##### Recursive functions for multipass antialiasing #####

function xaa_sr(clip input, string "type", int "passes", bool "chroma", string "cplace", int "snaa",
\               int "nns", float "alpha", float "beta", float "gamma", string "sclip", clip "mclip",
\               int "f") {

iw = input.Width()
ih = input.Height()

type   = Default(type, "SangNom2")
passes = Default(passes, 1)
chroma = Default(chroma, true)
cplace = Default(cplace, "MPEG2")
snaa   = Default(snaa, 48)
sclip  = Default(sclip, "")
f      = Default(f, 1)

# Alternate the field every pass, starting with 1 by default
field   = f%2
snfield = field == 1 ? 1 : 2

# SeparateFields will throw an error from mod2 heights if the input is YV12,
# so don't define sf unless it's needed, in which case the resolution will have been padded to mod4.
pad8 = type == "eedi2" || type == "eedi3" && sclip != "" && sclip != "SangNom2" && sclip != "nnedi3" ? true : false
sf   = pad8 ? input.AssumeTFF().SeparateFields() : Undefined()
sf   = pad8 && field == 1 ? sf.SelectEven()
\    : pad8               ? sf.SelectOdd()
\                         : Undefined()

# Use a src_top shift dependent on the field when resizing for the sclip to keep it in alignment with the eedi3 clip.
# Additionally, the vertical shift for YV12 chroma is doubled, so the chroma must be resized separately.
rshift = field == 1 ? 0.25 : -0.25

sclip2 = sclip == ""          ? Undefined()
\      : sclip == "SangNom2"  ? input.SangNom2(snfield,snaa,0)
\      : sclip == "nnedi3"    ? input.nnedi3(field, U=chroma, V=chroma, nns=nns)
\      : sclip == "eedi2"     ? sf.eedi2(field=field)
\                             : chroma && input.Is420() ? sf.ResizeX(iw,ih,0,rshift, kernel=sclip, chroma=false)
                                \                            .MergeChroma(sf.ResizeX(iw,ih,0,rshift*2.0, kernel=sclip, cplace=cplace, luma=false))
                                \                        : sf.ResizeX(iw,ih,0,rshift, kernel=sclip, cplace=cplace, chroma=chroma)

aa = type == "SangNom2"  ? input.SangNom2(snfield,snaa,0)
\  : type == "nnedi3"    ? input.nnedi3(field, U=chroma, V=chroma, nns=nns)
\  : type == "eedi3"     ? input.eedi3(field,false,true,chroma,chroma,alpha,beta,gamma, sclip=sclip2, mclip=mclip)
\  : type == "eedi2"     ? sf.eedi2(field=field)
\                        : Assert(false, "xaa_sr: invalid antialiasing type")


return passes > 0 ? aa.xaa_sr(type,passes-1,chroma,cplace,snaa,nns,alpha,beta,gamma,sclip,mclip,f+1)
\                 : input
}

function xaa_dr(clip input, string "type", int "passes", bool "chroma", string "cplace", int "snaa",
\               int "nns", float "alpha", float "beta", float "gamma", string "sclip", clip "mclip") {

iw = input.Width()
ih = input.Height()

type   = Default(type, "nnedi3")
passes = Default(passes, 1)
chroma = Default(chroma, true)
cplace = Default(cplace, "MPEG2")
snaa   = Default(snaa, 48)
sclip  = Default(sclip, "")

pad8  = type == "eedi2" || type == "eedi3" && sclip != "" && sclip != "SangNom2" && sclip != "nnedi3" ? true : false
sf    = pad8 ? input.AssumeTFF().SeparateFields() : Undefined()
tf    = pad8 ? sf.SelectEven() : Undefined()
bf    = pad8 ? sf.SelectOdd() : Undefined()
UVint = chroma ? 3 : 1

sclip2 = sclip == ""          ? Undefined()
\      : sclip == "SangNom2"  ? input.DoubleWeave().SangNom2(0,snaa,0)
\      : sclip == "nnedi3"    ? input.nnedi3(3, nns=nns, U=chroma, V=chroma)
\      : sclip == "eedi2"     ? sf.eedi2(field=3)
\                             : chroma && input.IsYV12() ? Interleave(tf.ResizeX(iw,ih,0,0.25, kernel=sclip, chroma=false),
                                \                                     bf.ResizeX(iw,ih,0,-0.25, kernel=sclip, chroma=false))
                                \                         .MergeChroma(Interleave(tf.ResizeX(iw,ih,0,0.5, kernel=sclip, cplace=cplace, luma=false),
                                \                                                 bf.ResizeX(iw,ih,0,-0.5, kernel=sclip, cplace=cplace, luma=false)))
                                \                        : Interleave(tf.ResizeX(iw,ih,0,0.25, kernel=sclip, cplace=cplace, chroma=chroma),
                                \                                     bf.ResizeX(iw,ih,0,-0.25, kernel=sclip, cplace=cplace, chroma=chroma))

aa = type == "SangNom2"  ? input.DoubleWeave().SangNom2(0,snaa,0)
\  : type == "nnedi3"    ? input.nnedi3(3, nns=nns, U=chroma, V=chroma)
\  : type == "eedi3"     ? input.eedi3(3,false,true,chroma,chroma,alpha,beta,gamma, sclip=sclip2, mclip=mclip)
\  : type == "eedi2"     ? sf.eedi2(field=3)
\                        : Assert(false, "xaa_dr: invalid antialiasing type")
aa = mt_average(aa.SelectEven(),aa.SelectOdd(), U=UVint, V=UVint)

return passes > 0 ? aa.xaa_dr(type,passes-1,chroma,cplace,snaa,nns,alpha,beta,gamma,sclip,mclip)
\                 : input
}

function xaa_di(clip input, string "type", int "passes", bool "chroma", string "cplace", int "snaa",
\               int "nns", float "alpha", float "beta", float "gamma", string "sclip", clip "mclip",
\               int "f", bool "dh") {

iw = input.Width()
ih = input.Height()

type   = Default(type, "nnedi3")
passes = Default(passes, 1)
chroma = Default(chroma, true)
cplace = Default(cplace, "MPEG2")
snaa   = Default(snaa, 48)
sclip  = Default(sclip, "")
f      = Default(f, 1)
dh     = Default(dh, true)

# Alternate the field every pass, starting with 1.
# Don't change the f value from the default or else the center shift correction will be wrong.
field   = f%2
snfield = field == 1 ? 1 : 2

pad8   = type == "eedi2" || type == "eedi3" && sclip != "" && sclip != "SangNom2" && sclip != "nnedi3" && sclip != "nnedi3ocl" ? true : false
sf     = pad8 ? input.AssumeTFF().SeparateFields() : Undefined()
sf     = pad8 && field == 1 ? sf.SelectEven()
\      : pad8               ? sf.SelectOdd()
\                           : Undefined()
rshift = field == 1 ? 0.25 : -0.25
UVint  = chroma ? 3 : 1

sclip2 = sclip == ""               ? Undefined()
\      : sclip == "SangNom2" && dh ? input.ResizeX(iw,ih*2, kernel="Point", cplace=cplace, chroma=chroma).SangNom2(snfield,snaa,0)
\      : sclip == "SangNom2"       ? input.SangNom2(snfield,snaa,0)
\      : sclip == "nnedi3"         ? input.nnedi3(field,dh, U=chroma, V=chroma, nns=nns)
\      : sclip == "eedi2"    && dh ? input.eedi2(field=field)
\      : sclip == "eedi2"          ? sf.eedi2(field=field)
\      :                        dh ? chroma && input.IsYV12() ? input.ResizeX(iw,ih*2,0,rshift, kernel=sclip, chroma=false)
                                     \                               .MergeChroma(input.ResizeX(iw,ih*2,0,rshift*2.0, kernel=sclip, cplace=cplace, luma=false))
                                     \                        : input.ResizeX(iw,ih*2,0,rshift, kernel=sclip, cplace=cplace, chroma=chroma)
\                                  : chroma && input.IsYV12() ? sf.ResizeX(iw,ih,0,rshift, kernel=sclip, chroma=false)
                                     \                            .MergeChroma(sf.ResizeX(iw,ih,0,rshift*2.0, kernel=sclip, cplace=cplace, luma=false))
                                     \                        : sf.ResizeX(iw,ih,0,rshift, kernel=sclip, cplace=cplace, chroma=chroma)

# The height is only doubled on the first pass
aa = type == "SangNom2" && dh ? input.ResizeX(iw,ih*2, kernel="Point", cplace=cplace, chroma=chroma).SangNom2(snfield,snaa,0)
\  : type == "SangNom2"       ? input.SangNom2(snfield,snaa,0)
\  : type == "nnedi3"         ? input.nnedi3(field,dh, U=chroma, V=chroma, nns=nns)
\  : type == "eedi3"          ? input.eedi3(field,dh,true,chroma,chroma,alpha,beta,gamma, sclip=sclip2, mclip=mclip)
\  : type == "eedi2"    && dh ? input.eedi2(field=field)
\  : type == "eedi2"          ? sf.eedi2(field=field)
\                             : Assert(false, "xaa_di: invalid antialiasing type")

# Double the height of the mclip for passes after the first.
mclip = mclip.Defined() && dh     &&
\       input.IsYV12()  && chroma  ? mclip.ResizeX(iw,ih*2,0,0.25, chroma=false)
\                                         .MergeChroma(mclip.ResizeX(iw,ih*2,0,0.5, cplace=cplace, luma=false))
\                                         .mt_binarize(128, U=3, V=3)
\     : mclip.Defined() && dh      ? mclip.ResizeX(iw,ih*2,0,0.25, cplace=cplace, chroma=chroma).mt_binarize(128, U=UVint, V=UVint)
\                                  : mclip

return passes > 0 ? aa.xaa_di(type,passes-1,chroma,cplace,snaa,nns,alpha,beta,gamma,sclip,mclip,f+1,false)
\                 : input
}