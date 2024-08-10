const t=[Int8Array,Uint8Array,Uint8ClampedArray,Int16Array,Uint16Array,Int32Array,Uint32Array,Float32Array,Float64Array];
/** @typedef {Int8ArrayConstructor | Uint8ArrayConstructor | Uint8ClampedArrayConstructor | Int16ArrayConstructor | Uint16ArrayConstructor | Int32ArrayConstructor | Uint32ArrayConstructor | Float32ArrayConstructor | Float64ArrayConstructor} TypedArrayConstructor */const s=1;const n=8;class KDBush{
/**
     * Creates an index from raw `ArrayBuffer` data.
     * @param {ArrayBuffer} data
     */
static from(n){if(!(n instanceof ArrayBuffer))throw new Error("Data must be an instance of ArrayBuffer.");const[r,e]=new Uint8Array(n,0,2);if(219!==r)throw new Error("Data does not appear to be in a KDBush format.");const i=e>>4;if(i!==s)throw new Error(`Got v${i} data when expected v${s}.`);const o=t[15&e];if(!o)throw new Error("Unrecognized array type.");const[a]=new Uint16Array(n,2,1);const[h]=new Uint32Array(n,4,1);return new KDBush(h,a,o,n)}
/**
     * Creates an index that will hold a given number of items.
     * @param {number} numItems
     * @param {number} [nodeSize=64] Size of the KD-tree node (64 by default).
     * @param {TypedArrayConstructor} [ArrayType=Float64Array] The array type used for coordinates storage (`Float64Array` by default).
     * @param {ArrayBuffer} [data] (For internal use only)
     */constructor(r,e=64,i=Float64Array,o){if(isNaN(r)||r<0)throw new Error(`Unpexpected numItems value: ${r}.`);this.numItems=+r;this.nodeSize=Math.min(Math.max(+e,2),65535);this.ArrayType=i;this.IndexArrayType=r<65536?Uint16Array:Uint32Array;const a=t.indexOf(this.ArrayType);const h=2*r*this.ArrayType.BYTES_PER_ELEMENT;const c=r*this.IndexArrayType.BYTES_PER_ELEMENT;const p=(8-c%8)%8;if(a<0)throw new Error(`Unexpected typed array class: ${i}.`);if(o&&o instanceof ArrayBuffer){this.data=o;this.ids=new this.IndexArrayType(this.data,n,r);this.coords=new this.ArrayType(this.data,n+c+p,2*r);this._pos=2*r;this._finished=true}else{this.data=new ArrayBuffer(n+h+c+p);this.ids=new this.IndexArrayType(this.data,n,r);this.coords=new this.ArrayType(this.data,n+c+p,2*r);this._pos=0;this._finished=false;new Uint8Array(this.data,0,2).set([219,(s<<4)+a]);new Uint16Array(this.data,2,1)[0]=e;new Uint32Array(this.data,4,1)[0]=r}}
/**
     * Add a point to the index.
     * @param {number} x
     * @param {number} y
     * @returns {number} An incremental index associated with the added item (starting from `0`).
     */add(t,s){const n=this._pos>>1;this.ids[n]=n;this.coords[this._pos++]=t;this.coords[this._pos++]=s;return n}finish(){const t=this._pos>>1;if(t!==this.numItems)throw new Error(`Added ${t} items when expected ${this.numItems}.`);sort(this.ids,this.coords,this.nodeSize,0,this.numItems-1,0);this._finished=true;return this}
/**
     * Search the index for items within a given bounding box.
     * @param {number} minX
     * @param {number} minY
     * @param {number} maxX
     * @param {number} maxY
     * @returns {number[]} An array of indices correponding to the found items.
     */range(t,s,n,r){if(!this._finished)throw new Error("Data not yet indexed - call index.finish().");const{ids:e,coords:i,nodeSize:o}=this;const a=[0,e.length-1,0];const h=[];while(a.length){const c=a.pop()||0;const p=a.pop()||0;const d=a.pop()||0;if(p-d<=o){for(let o=d;o<=p;o++){const a=i[2*o];const c=i[2*o+1];a>=t&&a<=n&&c>=s&&c<=r&&h.push(e[o])}continue}const f=d+p>>1;const u=i[2*f];const w=i[2*f+1];u>=t&&u<=n&&w>=s&&w<=r&&h.push(e[f]);if(0===c?t<=u:s<=w){a.push(d);a.push(f-1);a.push(1-c)}if(0===c?n>=u:r>=w){a.push(f+1);a.push(p);a.push(1-c)}}return h}
/**
     * Search the index for items within a given radius.
     * @param {number} qx
     * @param {number} qy
     * @param {number} r Query radius.
     * @returns {number[]} An array of indices correponding to the found items.
     */within(t,s,n){if(!this._finished)throw new Error("Data not yet indexed - call index.finish().");const{ids:r,coords:e,nodeSize:i}=this;const o=[0,r.length-1,0];const a=[];const h=n*n;while(o.length){const c=o.pop()||0;const p=o.pop()||0;const d=o.pop()||0;if(p-d<=i){for(let n=d;n<=p;n++)sqDist(e[2*n],e[2*n+1],t,s)<=h&&a.push(r[n]);continue}const f=d+p>>1;const u=e[2*f];const w=e[2*f+1];sqDist(u,w,t,s)<=h&&a.push(r[f]);if(0===c?t-n<=u:s-n<=w){o.push(d);o.push(f-1);o.push(1-c)}if(0===c?t+n>=u:s+n>=w){o.push(f+1);o.push(p);o.push(1-c)}}return a}}
/**
 * @param {Uint16Array | Uint32Array} ids
 * @param {InstanceType<TypedArrayConstructor>} coords
 * @param {number} nodeSize
 * @param {number} left
 * @param {number} right
 * @param {number} axis
 */function sort(t,s,n,r,e,i){if(e-r<=n)return;const o=r+e>>1;select(t,s,o,r,e,i);sort(t,s,n,r,o-1,1-i);sort(t,s,n,o+1,e,1-i)}
/**
 * Custom Floyd-Rivest selection algorithm: sort ids and coords so that
 * [left..k-1] items are smaller than k-th item (on either x or y axis)
 * @param {Uint16Array | Uint32Array} ids
 * @param {InstanceType<TypedArrayConstructor>} coords
 * @param {number} k
 * @param {number} left
 * @param {number} right
 * @param {number} axis
 */function select(t,s,n,r,e,i){while(e>r){if(e-r>600){const o=e-r+1;const a=n-r+1;const h=Math.log(o);const c=.5*Math.exp(2*h/3);const p=.5*Math.sqrt(h*c*(o-c)/o)*(a-o/2<0?-1:1);const d=Math.max(r,Math.floor(n-a*c/o+p));const f=Math.min(e,Math.floor(n+(o-a)*c/o+p));select(t,s,n,d,f,i)}const o=s[2*n+i];let a=r;let h=e;swapItem(t,s,r,n);s[2*e+i]>o&&swapItem(t,s,r,e);while(a<h){swapItem(t,s,a,h);a++;h--;while(s[2*a+i]<o)a++;while(s[2*h+i]>o)h--}if(s[2*r+i]===o)swapItem(t,s,r,h);else{h++;swapItem(t,s,h,e)}h<=n&&(r=h+1);n<=h&&(e=h-1)}}
/**
 * @param {Uint16Array | Uint32Array} ids
 * @param {InstanceType<TypedArrayConstructor>} coords
 * @param {number} i
 * @param {number} j
 */function swapItem(t,s,n,r){swap(t,n,r);swap(s,2*n,2*r);swap(s,2*n+1,2*r+1)}
/**
 * @param {InstanceType<TypedArrayConstructor>} arr
 * @param {number} i
 * @param {number} j
 */function swap(t,s,n){const r=t[s];t[s]=t[n];t[n]=r}
/**
 * @param {number} ax
 * @param {number} ay
 * @param {number} bx
 * @param {number} by
 */function sqDist(t,s,n,r){const e=t-n;const i=s-r;return e*e+i*i}export{KDBush as default};

