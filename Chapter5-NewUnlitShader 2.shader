// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/NewUnlitShader 2" {
    SubShader {
        Pass {
            CGPROGRAM
            
            #pragma vertex vert // 指定顶点着色器函数叫vert
            #pragma fragment frag // 指定片元着色器函数叫frag

            #include "UnityCG.cginc" // 引入Unity内置cg工具库，UnityObjectToClipPos就在这里

            // v2f：vertex to fragment，顶点着色器输出，传给片元着色器的数据结构体
            struct v2f {
                float4 pos : SV_POSITION; // 裁剪空间坐标，必须写SV_POSITION，光栅化要用
                fixed4 color : COLOR0; // 输出颜色，传给片元
                }; //结构体的花括号必须加;

            // appdata_full：Unity内置结构体，包含顶点全部原始数据：位置、法线、切线、uv0、uv1等
            v2f vert(appdata_full v) {
                v2f o;

                // 把模型本地顶点坐标，变换到相机裁剪空间（MVP变换）
                o.pos = UnityObjectToClipPos(v.vertex);

                // 1. 可视化法线：法线范围[-1,1] → 映射到[0,1]颜色
                o.color = fixed4(v.normal * 0.5 + fixed3(0.5,0.5,0.5), 1.0); //1.0是补全Alpha通道的值

                // 2. 可视化切线
                o.color = fixed4(v.tangent * 0.5 + fixed3(0.5,0.5,0.5), 1.0);

                // 3. 计算副法线，法线与切线叉乘，tangent.w是uv的方向（-1或+1），存储在tangent中方便计算，本身不属于切线，用于法线贴图
                fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w; 

                // 可视化副法线
                o.color = fixed4(binormal * 0.5 + fixed3(0.5,0.5,0.5), 1.0);

                // 4. 可视化第一套UV（texcoord / uv0），R=u，G=v，B=0
                o.color = fixed4(v.texcoord.xy, 0.0, 1.0);

                // 5. 可视化第二套UV（texcoord1 / uv1），R=u，G=v，B=0
                o.color = fixed4(v.texcoord1.xy, 0.0, 1.0);

                o.color = frac(v.texcoord); // frac()，取小数部分，R=u，G=v
                if (any(saturate(v.texcoord) - v.texcoord)) { //saturate(x) 是 HLSL 内置函数，把每个分量的数值钳制在 [0, 1] 区间：小于0 → 0，大于1 → 1，[0,1] → 取值不变
                    o.color.b = 0.5;                          //any(向量），只要向量里面，任意一个分量不是 0 → 返回 true；全部都是 0 → 返回 false
                    }
                o.color.a = 1.0;

                o.color = frac(v.texcoord1);
                if (any(saturate(v.texcoord1) - v.texcoord1)) {
                    o.color.b = 0.5;
                    }
                o.color.a = 1.0;

                return o; //局部变量o（v2f类型）的值作为函数vert（v2f类型）的返回值
                }

            fixed4 frag(v2f i) : SV_Target { // 光栅会对三个顶点的每一个成员做线性插值计算，生成三角形内部每一个像素对应的全新 v2f 实例，这个新实例名字叫i。
                return i.color;
                }
                
            ENDCG
            }
        }
    }