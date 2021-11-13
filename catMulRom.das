


def Hermite(P0: float2; P1: float2; T0:float2; T1: float2; t: float) : float2
	var x : float = ((1.0f - 3.0f * (t*t) + 2.0f * (t*t*t)) * P0.x +((t*t) * (3.0f - 2.0f * t)) * P1.x + (t * ((t-1.0)*(t-1.0))) * T0.x +((t*t) * (t - 1.0f)) * T1.x)
	
    var y : float = (1.0f - 3.0f * (t*t) + 2.0f * (t*t*t)) * P0.y + ((t*t) * (3.0f - 2.0f * t)) * P1.y + (t * ((t-1.0)*(t-1.0))) * T0.y + ((t*t) * (t - 1.0f)) * T1.y
	return float2(x, y)

	// var prevTangent = 0.0;
	// var epsilon = 0.01f;
	// for i in range (1, points.count)
	// 	var dx = points[i + 1].x - points[i - 1].x;
	// 	var dy = points[i + 1].y - points[i - 1].y;

	// 	// first derivative of points (speed on y axis)
	// 	var tangent = (dx == 0.0) ? 0.0f : dy / dx;
	// 	// second derivative of points (acceleration on y axis)
	// 	var acc = 100.0 * ((dx == 0.0) ? 0.0f : (tangent - prevTangent) / dx);
        
	// 	if (acc < -epsilon || acc > epsilon) // reject zero with an epsilon
	// 	{
	// 		//color = (acc > 0) ? summitColor : valleyColor;
	// 		color = lerp(valleyColor, summitColor, 0.5f*(acc) + 0.5f);
	// 	}
	// 	prevTangent = tangent;

	// 	m_vertices[i].color = color;

def _Compute(p0 : float2; p1 : float2; p2 : float2; p3 : float2; t : float) : float2
	var x = (2.0 * p1.x) + (-p0.x + p2.x) * t + (2.0 * p0.x - 5.0 * p1.x + 4.0 * p2.x - p3.x) * t*t + (-p0.x + 3.0 * p1.x - 3.0 * p2.x + p3.x) * t*t*t;

	var y = (2.0 * p1.y) + (-p0.y + p2.y) * t + (2.0 * p0.y - 5.0 * p1.y + 4.0 * p2.y - p3.y) * t*t + (-p0.y + 3.0 * p1.y - 3.0 * p2.y + p3.y) * t*t*t;

	return 0.5f * float2(x, y);