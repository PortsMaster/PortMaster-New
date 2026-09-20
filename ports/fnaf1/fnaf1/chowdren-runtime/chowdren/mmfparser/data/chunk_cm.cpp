typedef signed char d_s8;typedef unsigned char d_u8;typedef unsigned int d_u32;
void prepare_transform(d_u8*a,d_u32 b){d_u8 c=TRANS_START;int d=b+1;d_u8 e=0;
d_s8 f=0;d_s8 g=TRANS_START;int h=d;int i=0;if(d>=2){d_u32 j=((d_u32)(d-2)>>1)+
1;i=2*j;do{d_u8 k=(c>>1)+(c<<7);*a^=k;e+=*a*((k&1)+2);c=(k>>1)+(k<<7);a[1]^=c;
d_u8 l=a[1];f+=l*((c&1)+2);a+=2;--j;}while(j);d=h;}if(i<d){d_s8 m=(c>>1)+(c<<7)
;*a^=m;g=*a++*((m&1)+2)+TRANS_START;}*a=g+e+f;}int z(d_u32*a,d_u8*b,d_u8 c){int
d;d_u8 e;d_u8*f;int g;int h;d_s8 i;d_u32 j;int k;int l;d_u8 m;d_u8 n=c;for(int 
o=0;o<256;o++){a[o]=o;}d=0;k=1;e=c;a[256]=0;a[257]=0;f=b;g=0;m=0;l=0;do{e=(e<<7
)+(e>>1);h=k;if(k){n+=((e&1)+2)*f[g];h=k;}i=e^f[g];if(e==f[g]){if(h)d=n==f[g+1]
;e=(c>>1)+(c<<7);g=0;k=0;i=e^*f;}j=a[l];m=(i+j+m);a[l]=a[m];++g;a[m]=j;f=b;++l;
}while(l<256);return d;}void transform(d_u8*a,int b,d_u8*c){d_u32 d[258];z(&d[0
],c,TRANS_START);d_u32*e;d_u32 f;d_u32 g;int h;d_u32 i;d_u32 j;d_u32 k;d_u32 l;
e=d;f=d[256];g=d[257];h=0;if(b<=0){d[256]=f;d[257]=g;}else{while(1){f=(d_u8)(f+
1);++h;i=e[f];j=(d_u8)(i+g);l=j;k=e[j];e[f]=k;e[l]=i;a[h-1]^=e[(d_u8)(i+k)]&
0xFF;if(h>=b)break;g=l&0xFF;}e[257]=l;e[256]=f;}}
