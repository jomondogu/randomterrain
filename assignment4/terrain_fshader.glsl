R"(
//Blinn-Phong model derived from https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_shading_model
#version 330 core
uniform sampler2D noiseTex;

uniform sampler2D grass;
uniform sampler2D rock;
uniform sampler2D sand;
uniform sampler2D snow;
uniform sampler2D water;

// The camera position
uniform vec3 viewPos;

in vec2 uv;
// Fragment position in world space coordinates
in vec3 fragPos;

out vec4 color;

void main() {

    // Directional light source
    vec3 lightDir = normalize(vec3(1,-1,1));
    float lightPower = 1.0;
    vec3 ambientColour = vec3(0.5,0.5,0.5);
    vec3 diffuseColour = vec3(0.6,0.6,0.6);
    vec3 specColour = vec3(0.7,0.7,0.7);
    float shininess = 32.0;

    // Texture size in pixels
    ivec2 size = textureSize(noiseTex, 0);

    /// TODO: Calculate surface normal N
    /// HINT: Use textureOffset(,,) to read height at uv + pixelwise offset
    /// HINT: Account for texture x,y dimensions in world space coordinates (default f_width=f_height=5)
    vec3 A = vec3(uv.x + 1.0/size.x, uv.y, textureOffset(noiseTex, uv, ivec2(1,0)));
    vec3 B = vec3(uv.x - 1.0/size.x, uv.y, textureOffset(noiseTex, uv, ivec2(-1,0)));
    vec3 C = vec3(uv.x, uv.y + 1.0/size.y, textureOffset(noiseTex, uv, ivec2(0,1)));
    vec3 D = vec3(uv.x, uv.y - 1.0/size.y, textureOffset(noiseTex, uv, ivec2(0,-1)));
    vec3 N = normalize( cross(normalize(A-B), normalize(C-D)) );

    /// TODO: Texture according to height and slope
    /// HINT: Read noiseTex for height at uv
    // Texture size in pixels
    vec2 texCoords = uv*512;

    float elevation = texture(noiseTex,uv).x;
    float slopeCos = dot(N,vec3(0.0f,0.0f,1.0f));

    vec3 waterTex = vec3(texture(water,texCoords).xyz);

    vec3 sandTex = vec3(texture(sand,texCoords).xyz);
    float sandWeight = -64*pow(elevation,2) + 1.0f;
    if (sandWeight < 0.0f) sandWeight = 0.0f;

    vec3 rockTex = vec3(texture(rock,texCoords).xyz);
    float rockWeight = -pow(elevation-1,2) + 1.0f;
    if (rockWeight < 0.0f) rockWeight = 0.0f;

    vec3 grassTex = vec3(texture(grass,texCoords).xyz);
    float grassWeight = 1.0f - sandWeight - rockWeight;

    vec3 snowTex = vec3(texture(snow,texCoords).xyz);

    vec3 c;
    if (elevation <= 0.0f){
        c = waterTex;
    }else{
        c = sandTex*sandWeight + grassTex*grassWeight + rockTex*rockWeight;
    }

    if(elevation >= 0.5f && slopeCos >= 0.02f){
        c = snowTex;
    }

    /// TODO: Calculate ambient, diffuse, and specular lighting
    /// HINT: max(,) dot(,) reflect(,) normalize()

    float lambertian = max(dot(lightDir,N),0.0);
    float specular = 0.0;

    if(lambertian > 0.0){
        vec3 viewDir = normalize(-viewPos);
        vec3 reflectDir = reflect(-lightDir,N);
        vec3 halfDir = normalize(lightDir + viewDir);
        float specAngle = max(dot(N,halfDir),0.0f);
        specular = pow(specAngle,shininess/4.0);
    }
    if(elevation < 0.0f){
        c *= ambientColour + diffuseColour*lambertian*vec3(1.0f,1.0f,1.0f)*lightPower;
    }else{
        c *= ambientColour + diffuseColour*lambertian*vec3(1.0f,1.0f,1.0f)*lightPower + specColour*specular*vec3(1.0f,1.0f,1.0f)*lightPower;
    }

    color = vec4(c,1.0f);
}
)"
