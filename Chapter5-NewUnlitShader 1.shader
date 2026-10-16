Shader "Unlit/NewUnlitShader 1"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0) //1.0 全部改为 1 无影响
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" } //标记这是不透明物体,后期渲染有用，这里不影响
        LOD 100  //这个 SubShader 只在 LOD 值≥100的时候启用，现在用的模型没有配置 LOD Group，永远用最高 LOD，删掉无影响

        Pass
        {
            CGPROGRAM

            #pragma vertex vert // 指定顶点着色器函数叫vert
            #pragma fragment frag // 指定片元着色器函数叫frag

            #include "UnityCG.cginc" //试了下把这行删掉无影响，原因可能是 UnityObjectToClipPos()，有一部分版本unity会把它的声明内置进引擎预编译环境，不是强制依赖 UnityCG.cginc

            fixed4 _Color;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0; //这行删掉无影响，没有纹理
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 color : COLOR0; //COLOR0 也可替换为 TEXCOORD0
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = normalize(v.normal) * 0.5 + fixed3(0.5,0.5,0.5); //normalize 使向量归一化，在这里删掉没影响，原因是模型法线本身就是单位向量
                return o;                                 // fixed3(0.5,0.5,0.5) 改为 0.5无影响
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 c = i.color;
                c *= _Color.rgb;
                return fixed4(c, 1.0); //这个{}内三行可以替换为 return fixed4(i.color * _Color.rgb, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
