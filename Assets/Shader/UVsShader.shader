Shader "Custom/UVControl"
{
    Properties
    {
        [NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
        _PuzzleSize("PuzzleSize", Float) = 1
        _PiecePosition("PiecePosition", Vector) = (0, 0, 0, 0)
        _Rounded("Rounded", Range(0, 1)) = 0.2
        _Margin("Margin", Range(0, 1)) = 0.95
        _BorderBaseColor("BorderBaseColor", Color) = (1, 0.7083604, 0.2688679, 0)
        _BorderGradient("BorderGradient", Float) = 3.81
        _BorderGradientColor("BorderGradientColor", Color) = (1, 0.8454475, 0, 0)
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
    SubShader
    {
        Tags
        {
            // RenderPipeline: <None>
            "RenderType"="Transparent"
            "BuiltInMaterialType" = "Unlit"
            "Queue"="Transparent"
            // DisableBatching: <None>
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="BuiltInUnlitSubTarget"
        }
        Pass
        {
            Name "Pass"
        
        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off
        ColorMask RGB
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile_fwdbase
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define BUILTIN_TARGET_API 1
        #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
        #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
        #endif
        #ifdef _BUILTIN_ALPHATEST_ON
        #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
        #endif
        #ifdef _BUILTIN_AlphaClip
        #define _AlphaClip _BUILTIN_AlphaClip
        #endif
        #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
        #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
        #endif
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_TexelSize;
        float _PuzzleSize;
        float2 _PiecePosition;
        float _Rounded;
        float _Margin;
        float _BorderGradient;
        float4 _BorderBaseColor;
        float4 _BorderGradientColor;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // Graph Functions
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }
        
        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }
        
        void Unity_RoundedRectangle_float(float2 UV, float Width, float Height, float Radius, out float Out)
        {
            Radius = max(min(min(abs(Radius * 2), abs(Width)), abs(Height)), 1e-5);
            float2 uv = abs(UV * 2 - 1) - float2(Width, Height) + Radius;
            float d = length(max(0, uv)) / Radius;
        #if defined(SHADER_STAGE_RAY_TRACING)
            Out = saturate((1 - d) * 1e7);
        #else
            float fwd = max(fwidth(d), 1e-5);
            Out = saturate((1 - d) / fwd);
        #endif
        }
        
        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_5e8cb3af8b0a4f7295400a7c7088ba71_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
            float _Property_f389ad0ba76e4fc793c9bc950b5ab461_Out_0_Float = _PuzzleSize;
            float _Divide_515037e924774b7bb95a32a3797190ad_Out_2_Float;
            Unity_Divide_float(float(1), _Property_f389ad0ba76e4fc793c9bc950b5ab461_Out_0_Float, _Divide_515037e924774b7bb95a32a3797190ad_Out_2_Float);
            float2 _Vector2_52b209f5ec18489994f44fbce871b612_Out_0_Vector2 = float2(_Divide_515037e924774b7bb95a32a3797190ad_Out_2_Float, _Divide_515037e924774b7bb95a32a3797190ad_Out_2_Float);
            float2 _Property_42ce2ab45c9d46aaa0f9c3b8e2430a54_Out_0_Vector2 = _PiecePosition;
            float _Split_6a14b3d6b0d44858ac3160fef5ecd7a4_R_1_Float = _Property_42ce2ab45c9d46aaa0f9c3b8e2430a54_Out_0_Vector2[0];
            float _Split_6a14b3d6b0d44858ac3160fef5ecd7a4_G_2_Float = _Property_42ce2ab45c9d46aaa0f9c3b8e2430a54_Out_0_Vector2[1];
            float _Split_6a14b3d6b0d44858ac3160fef5ecd7a4_B_3_Float = 0;
            float _Split_6a14b3d6b0d44858ac3160fef5ecd7a4_A_4_Float = 0;
            float _Property_946aeff6f54c4592b8709f2f5ad7ae5b_Out_0_Float = _PuzzleSize;
            float _Divide_b0f69ba676ab4b23b6095ec050eab96c_Out_2_Float;
            Unity_Divide_float(_Split_6a14b3d6b0d44858ac3160fef5ecd7a4_R_1_Float, _Property_946aeff6f54c4592b8709f2f5ad7ae5b_Out_0_Float, _Divide_b0f69ba676ab4b23b6095ec050eab96c_Out_2_Float);
            float _Add_3effb99a2fe541cfb440c0e3dede35ba_Out_2_Float;
            Unity_Add_float(_Split_6a14b3d6b0d44858ac3160fef5ecd7a4_G_2_Float, float(1), _Add_3effb99a2fe541cfb440c0e3dede35ba_Out_2_Float);
            float _Subtract_4b8f6b3f8d2b43d8b15c45a532fbb736_Out_2_Float;
            Unity_Subtract_float(_Property_946aeff6f54c4592b8709f2f5ad7ae5b_Out_0_Float, _Add_3effb99a2fe541cfb440c0e3dede35ba_Out_2_Float, _Subtract_4b8f6b3f8d2b43d8b15c45a532fbb736_Out_2_Float);
            float _Divide_62e07a1611b14148af743822a9dc6fe2_Out_2_Float;
            Unity_Divide_float(_Subtract_4b8f6b3f8d2b43d8b15c45a532fbb736_Out_2_Float, _Property_946aeff6f54c4592b8709f2f5ad7ae5b_Out_0_Float, _Divide_62e07a1611b14148af743822a9dc6fe2_Out_2_Float);
            float2 _Vector2_bdb581f641eb4848b236dad16340e69b_Out_0_Vector2 = float2(_Divide_b0f69ba676ab4b23b6095ec050eab96c_Out_2_Float, _Divide_62e07a1611b14148af743822a9dc6fe2_Out_2_Float);
            float2 _TilingAndOffset_0b19cb1a59e14868a30ce95659121555_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_52b209f5ec18489994f44fbce871b612_Out_0_Vector2, _Vector2_bdb581f641eb4848b236dad16340e69b_Out_0_Vector2, _TilingAndOffset_0b19cb1a59e14868a30ce95659121555_Out_3_Vector2);
            float4 _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5e8cb3af8b0a4f7295400a7c7088ba71_Out_0_Texture2D.tex, _Property_5e8cb3af8b0a4f7295400a7c7088ba71_Out_0_Texture2D.samplerstate, _Property_5e8cb3af8b0a4f7295400a7c7088ba71_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_0b19cb1a59e14868a30ce95659121555_Out_3_Vector2) );
            float _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_R_4_Float = _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_RGBA_0_Vector4.r;
            float _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_G_5_Float = _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_RGBA_0_Vector4.g;
            float _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_B_6_Float = _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_RGBA_0_Vector4.b;
            float _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_A_7_Float = _SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_RGBA_0_Vector4.a;
            float4 _Property_8ddc3fbd754c4064b79cf6750619cd61_Out_0_Vector4 = _BorderBaseColor;
            float4 _Property_9712969086cf4b07adffbc2fd8ffa4ed_Out_0_Vector4 = _BorderGradientColor;
            float4 _UV_07652b66fe11442b87ec04ee388da111_Out_0_Vector4 = IN.uv0;
            float _Split_fe40736f98f749a293b47d95fa7f4f35_R_1_Float = _UV_07652b66fe11442b87ec04ee388da111_Out_0_Vector4[0];
            float _Split_fe40736f98f749a293b47d95fa7f4f35_G_2_Float = _UV_07652b66fe11442b87ec04ee388da111_Out_0_Vector4[1];
            float _Split_fe40736f98f749a293b47d95fa7f4f35_B_3_Float = _UV_07652b66fe11442b87ec04ee388da111_Out_0_Vector4[2];
            float _Split_fe40736f98f749a293b47d95fa7f4f35_A_4_Float = _UV_07652b66fe11442b87ec04ee388da111_Out_0_Vector4[3];
            float _Subtract_8beb7a59164942988c9a700ffa465512_Out_2_Float;
            Unity_Subtract_float(float(1), _Split_fe40736f98f749a293b47d95fa7f4f35_R_1_Float, _Subtract_8beb7a59164942988c9a700ffa465512_Out_2_Float);
            float _Multiply_cfc6681c69d8463d836a2868c879c320_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_8beb7a59164942988c9a700ffa465512_Out_2_Float, 2, _Multiply_cfc6681c69d8463d836a2868c879c320_Out_2_Float);
            float _Multiply_482c74b5407f4f4f8486cba1e6f5156a_Out_2_Float;
            Unity_Multiply_float_float(_Split_fe40736f98f749a293b47d95fa7f4f35_R_1_Float, 2, _Multiply_482c74b5407f4f4f8486cba1e6f5156a_Out_2_Float);
            float _Multiply_36e0c039e64443de977877775fef9f7d_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_cfc6681c69d8463d836a2868c879c320_Out_2_Float, _Multiply_482c74b5407f4f4f8486cba1e6f5156a_Out_2_Float, _Multiply_36e0c039e64443de977877775fef9f7d_Out_2_Float);
            float _Clamp_3e77b904b07d41aabe695cc8e5647823_Out_3_Float;
            Unity_Clamp_float(_Multiply_36e0c039e64443de977877775fef9f7d_Out_2_Float, float(0), float(1), _Clamp_3e77b904b07d41aabe695cc8e5647823_Out_3_Float);
            float _Multiply_af11bd5123424e70b85a80e19dfad92c_Out_2_Float;
            Unity_Multiply_float_float(_Split_fe40736f98f749a293b47d95fa7f4f35_G_2_Float, 2, _Multiply_af11bd5123424e70b85a80e19dfad92c_Out_2_Float);
            float _Subtract_3cdef756c5d044f1910921692c59f100_Out_2_Float;
            Unity_Subtract_float(float(1), _Split_fe40736f98f749a293b47d95fa7f4f35_G_2_Float, _Subtract_3cdef756c5d044f1910921692c59f100_Out_2_Float);
            float _Multiply_8a26e771d502463887dee688bc71ef19_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_3cdef756c5d044f1910921692c59f100_Out_2_Float, 2, _Multiply_8a26e771d502463887dee688bc71ef19_Out_2_Float);
            float _Multiply_3a2c5dbeef5b4585ba27638667070653_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_af11bd5123424e70b85a80e19dfad92c_Out_2_Float, _Multiply_8a26e771d502463887dee688bc71ef19_Out_2_Float, _Multiply_3a2c5dbeef5b4585ba27638667070653_Out_2_Float);
            float _Clamp_b23dc2e1c2764585b60e098e96588588_Out_3_Float;
            Unity_Clamp_float(_Multiply_3a2c5dbeef5b4585ba27638667070653_Out_2_Float, float(0), float(1), _Clamp_b23dc2e1c2764585b60e098e96588588_Out_3_Float);
            float _Multiply_44468bf6b3354439adc56d22ecca0391_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_3e77b904b07d41aabe695cc8e5647823_Out_3_Float, _Clamp_b23dc2e1c2764585b60e098e96588588_Out_3_Float, _Multiply_44468bf6b3354439adc56d22ecca0391_Out_2_Float);
            float _Subtract_edfba4457f8c4572982feb607396ef4e_Out_2_Float;
            Unity_Subtract_float(float(0.52), _Multiply_44468bf6b3354439adc56d22ecca0391_Out_2_Float, _Subtract_edfba4457f8c4572982feb607396ef4e_Out_2_Float);
            float _Multiply_aa02091b44174cebb29206c8709d58b9_Out_2_Float;
            Unity_Multiply_float_float(_Subtract_edfba4457f8c4572982feb607396ef4e_Out_2_Float, _Multiply_44468bf6b3354439adc56d22ecca0391_Out_2_Float, _Multiply_aa02091b44174cebb29206c8709d58b9_Out_2_Float);
            float _Multiply_e1ace13af21e457da273adfbb294b706_Out_2_Float;
            Unity_Multiply_float_float(_Multiply_aa02091b44174cebb29206c8709d58b9_Out_2_Float, 11, _Multiply_e1ace13af21e457da273adfbb294b706_Out_2_Float);
            float _Property_e44844f3a4ab4bc6866a45c81fb260a3_Out_0_Float = _BorderGradient;
            float _Power_28faf38365b74629a429ad0353078ca7_Out_2_Float;
            Unity_Power_float(_Multiply_e1ace13af21e457da273adfbb294b706_Out_2_Float, _Property_e44844f3a4ab4bc6866a45c81fb260a3_Out_0_Float, _Power_28faf38365b74629a429ad0353078ca7_Out_2_Float);
            float _Clamp_d6409ef3c1eb465fbd135d6f75c4ba5d_Out_3_Float;
            Unity_Clamp_float(_Power_28faf38365b74629a429ad0353078ca7_Out_2_Float, float(0), float(1), _Clamp_d6409ef3c1eb465fbd135d6f75c4ba5d_Out_3_Float);
            float _Property_382f91ef8eb84691a74334a32486fd7e_Out_0_Float = _Rounded;
            float _RoundedRectangle_d4435f00248948cea9c33a586202b3c4_Out_4_Float;
            Unity_RoundedRectangle_float(IN.uv0.xy, float(1), float(1), _Property_382f91ef8eb84691a74334a32486fd7e_Out_0_Float, _RoundedRectangle_d4435f00248948cea9c33a586202b3c4_Out_4_Float);
            float _Property_12d33971dd284f8291e2c0298d6f3dea_Out_0_Float = _Margin;
            float _RoundedRectangle_318e1c50563444e3b2269d5a4bfb3d14_Out_4_Float;
            Unity_RoundedRectangle_float(IN.uv0.xy, _Property_12d33971dd284f8291e2c0298d6f3dea_Out_0_Float, _Property_12d33971dd284f8291e2c0298d6f3dea_Out_0_Float, _Property_382f91ef8eb84691a74334a32486fd7e_Out_0_Float, _RoundedRectangle_318e1c50563444e3b2269d5a4bfb3d14_Out_4_Float);
            float _Subtract_d336951ba2a84f8b8f00b6ac63eb155b_Out_2_Float;
            Unity_Subtract_float(_RoundedRectangle_d4435f00248948cea9c33a586202b3c4_Out_4_Float, _RoundedRectangle_318e1c50563444e3b2269d5a4bfb3d14_Out_4_Float, _Subtract_d336951ba2a84f8b8f00b6ac63eb155b_Out_2_Float);
            float _Multiply_aacfe033e3f04cfc88480a6b72579901_Out_2_Float;
            Unity_Multiply_float_float(_Clamp_d6409ef3c1eb465fbd135d6f75c4ba5d_Out_3_Float, _Subtract_d336951ba2a84f8b8f00b6ac63eb155b_Out_2_Float, _Multiply_aacfe033e3f04cfc88480a6b72579901_Out_2_Float);
            float4 _Lerp_f7414df3f36c458e879e927e37de139f_Out_3_Vector4;
            Unity_Lerp_float4(_Property_8ddc3fbd754c4064b79cf6750619cd61_Out_0_Vector4, _Property_9712969086cf4b07adffbc2fd8ffa4ed_Out_0_Vector4, (_Multiply_aacfe033e3f04cfc88480a6b72579901_Out_2_Float.xxxx), _Lerp_f7414df3f36c458e879e927e37de139f_Out_3_Vector4);
            float4 _Lerp_4863f49cf37a45c08da39a2d2a1bca2a_Out_3_Vector4;
            Unity_Lerp_float4(_SampleTexture2D_6e0f9ccdc77b45049ccf17cebf617917_RGBA_0_Vector4, _Lerp_f7414df3f36c458e879e927e37de139f_Out_3_Vector4, (_Subtract_d336951ba2a84f8b8f00b6ac63eb155b_Out_2_Float.xxxx), _Lerp_4863f49cf37a45c08da39a2d2a1bca2a_Out_3_Vector4);
            surface.BaseColor = (_Lerp_4863f49cf37a45c08da39a2d2a1bca2a_Out_3_Vector4.xyz);
            surface.Alpha = _RoundedRectangle_d4435f00248948cea9c33a586202b3c4_Out_4_Float;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
            
        
        
        
        
        
        
            #if UNITY_UV_STARTS_AT_TOP
            #else
            #endif
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
        {
            result.vertex     = float4(attributes.positionOS, 1);
            result.tangent    = attributes.tangentOS;
            result.normal     = attributes.normalOS;
            result.texcoord   = attributes.uv0;
            result.vertex     = float4(vertexDescription.Position, 1);
            result.normal     = vertexDescription.Normal;
            result.tangent    = float4(vertexDescription.Tangent, 0);
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
        }
        
        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
        {
            result.pos = varyings.positionCS;
            // World Tangent isn't an available input on v2f_surf
        
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
        }
        
        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
        {
            result.positionCS = surfVertex.pos;
            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
            // World Tangent isn't an available input on v2f_surf
        
            #if UNITY_ANY_INSTANCING_ENABLED
            #endif
            #if UNITY_SHOULD_SAMPLE_SH
            #if !defined(LIGHTMAP_ON)
            #endif
            #endif
            #if defined(LIGHTMAP_ON)
            #endif
            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
            #endif
        
            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInUnlitGUI" ""
    FallBack "Hidden/Shader Graph/FallbackError"
}