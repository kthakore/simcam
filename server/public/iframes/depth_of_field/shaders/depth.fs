/// <summary>
/// Copyright (C) 2012 Nathaniel Meyer
/// Nutty Software, http://www.nutty.ca
/// All Rights Reserved.
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy of
/// this software and associated documentation files (the "Software"), to deal in
/// the Software without restriction, including without limitation the rights to
/// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
/// of the Software, and to permit persons to whom the Software is furnished to do
/// so, subject to the following conditions:
///     1. The above copyright notice and this permission notice shall be included in all
///        copies or substantial portions of the Software.
///     2. Redistributions in binary or minimized form must reproduce the above copyright
///        notice and this list of conditions in the documentation and/or other materials
///        provided with the distribution.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.
/// </summary>


/// <summary>
/// This fragment shader records the depth values of the geometry into a texture.
/// </summary>


#ifdef GL_ES
	precision highp float;
#endif


/// <summary>
/// Uniform variables.
/// <summary>
uniform float Near;
uniform float Far;


/// <summary>
/// Varying variables.
/// <summary>
varying vec4 vPosition;


/// <summary>
/// Pack a floating point value into an RGBA (32bpp).
///
/// Note that video cards apply some sort of bias (error?) to pixels,
/// so we must correct for that by subtracting the next component's
/// value from the previous component.
/// </summary>
vec4 pack (float depth)
{
	const vec4 bias = vec4(1.0 / 255.0,
							1.0 / 255.0,
							1.0 / 255.0,
							0.0);

	float r = depth;
	float g = fract(r * 255.0);
	float b = fract(g * 255.0);
	float a = fract(b * 255.0);
	vec4 colour = vec4(r, g, b, a);
	
	return colour - (colour.yzww * bias);
}


/// <summary>
/// Fragment shader entry.
/// </summary>
void main ()
{
	// Linear depth
	float linearDepth = length(vPosition) / (Far - Near);
	
	//gl_FragColor = pack(gl_FragCoord.z);
	gl_FragColor = pack(linearDepth);
}