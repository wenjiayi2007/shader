Shader "Unlit/Chapter6-DiffuseVertexLevel"
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
                fixed3 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); //当 mul 里面【向量放前面、矩阵放后面】，相当于：把输入的向量解释成行向量（等价于对列向量做一次转置）；逆矩阵保持原样不转置；行向量右乘逆矩阵，计算得到的结果，就是「逆转置矩阵左乘列向量」的结果再整体转置。但图形学的向量只是一组数字，只需要 xyz 分量，所以得到的结果不用再转置回去。
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);                      //_World2Object 是（4×4）齐次变换矩阵，由于法线不受平移影响，所以取（3×3）
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

                o.color = ambient + diffuse;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
