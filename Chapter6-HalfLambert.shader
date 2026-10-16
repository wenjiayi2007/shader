// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/Chapter6-HalfLambert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1) //为了得到并且控制材质的漫反射颜色，我们首先在shader的properties语义块中声明了一个Color类型的属性，初始值设为白色
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"} //内置管线前向渲染的基础 Pass。告诉 Unity：这个 Pass 用来算 主方向光 + 环境光，Unity 才会把 _LightColor0、_WorldSpaceLightPos0 这些光照变量注入进来。

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc" //引入 Unity 内置光照库，定义了 _LightColor0

            fixed4 _Diffuse; //为了在shader中使用properties语义块中声明的属性，我们需要定义一个和该属性类型相匹配的变量

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
