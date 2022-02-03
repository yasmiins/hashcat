/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

//#define NEW_SIMD_CODE

#define XSTR(x) #x
#define STR(x) XSTR(x)

#ifdef KERNEL_STATIC
#include STR(INCLUDE_PATH/inc_vendor.h)
#include STR(INCLUDE_PATH/inc_types.h)
#include STR(INCLUDE_PATH/inc_platform.cl)
#include STR(INCLUDE_PATH/inc_common.cl)
#include STR(INCLUDE_PATH/inc_scalar.cl)
#include STR(INCLUDE_PATH/inc_hash_ripemd160.cl)
#include STR(INCLUDE_PATH/inc_cipher_serpent.cl)
#endif

typedef struct cryptoapi
{
  u32 kern_type;
  u32 key_size;

} cryptoapi_t;

KERNEL_FQ void m14542_mxx (KERN_ATTR_VECTOR_ESALT (cryptoapi_t))
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * base
   */

  u32 serpent_key_len = esalt_bufs[DIGESTS_OFFSET_HOST].key_size;

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    ripemd160_ctx_t ctx0;

    ripemd160_init (&ctx0);

    ripemd160_update (&ctx0, w, pw_len);

    ripemd160_final (&ctx0);

    const u32 k0 = ctx0.h[0];
    const u32 k1 = ctx0.h[1];
    const u32 k2 = ctx0.h[2];
    const u32 k3 = ctx0.h[3];

    u32 k4 = 0, k5 = 0, k6 = 0, k7 = 0;

    if (serpent_key_len > 128)
    {
      k4 = ctx0.h[4];

      ripemd160_ctx_t ctx;

      ripemd160_init (&ctx);

      ctx.w0[0] = 0x00000041;

      ctx.len = 1;

      ripemd160_update (&ctx, w, pw_len);

      ripemd160_final (&ctx);

      k5 = ctx.h[0];

      if (serpent_key_len > 192)
      {
        k6 = ctx.h[1];
        k7 = ctx.h[2];
      }
    }

    // key

    u32 ukey[8] = { 0 };

    ukey[0] = k0;
    ukey[1] = k1;
    ukey[2] = k2;
    ukey[3] = k3;

    if (serpent_key_len > 128)
    {
      ukey[4] = k4;
      ukey[5] = k5;

      if (serpent_key_len > 192)
      {
        ukey[6] = k6;
        ukey[7] = k7;
      }
    }

    // IV

    const u32 iv[4] = {
      salt_bufs[SALT_POS_HOST].salt_buf[0],
      salt_bufs[SALT_POS_HOST].salt_buf[1],
      salt_bufs[SALT_POS_HOST].salt_buf[2],
      salt_bufs[SALT_POS_HOST].salt_buf[3]
    };

    // CT

    u32 CT[4] = { 0 };

    // serpent

    u32 ks[140] = { 0 };

    if (serpent_key_len == 128)
    {
      serpent128_set_key (ks, ukey);

      serpent128_encrypt (ks, iv, CT);
    }
    else if (serpent_key_len == 192)
    {
      serpent192_set_key (ks, ukey);

      serpent192_encrypt (ks, iv, CT);
    }
    else
    {
      serpent256_set_key (ks, ukey);

      serpent256_encrypt (ks, iv, CT);
    }

    const u32 r0 = hc_swap32_S (CT[0]);
    const u32 r1 = hc_swap32_S (CT[1]);
    const u32 r2 = hc_swap32_S (CT[2]);
    const u32 r3 = hc_swap32_S (CT[3]);

    COMPARE_M_SCALAR (r0, r1, r2, r3);
  }
}

KERNEL_FQ void m14542_sxx (KERN_ATTR_VECTOR_ESALT (cryptoapi_t))
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R0],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R1],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R2],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R3]
  };

  /**
   * base
   */

  u32 serpent_key_len = esalt_bufs[DIGESTS_OFFSET_HOST].key_size;

  const u32 pw_len = pws[gid].pw_len;

  u32x w[64] = { 0 };

  for (u32 i = 0, idx = 0; i < pw_len; i += 4, idx += 1)
  {
    w[idx] = pws[gid].i[idx];
  }

  /**
   * loop
   */

  u32x w0l = w[0];

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos += VECT_SIZE)
  {
    const u32x w0r = words_buf_r[il_pos / VECT_SIZE];

    const u32x w0 = w0l | w0r;

    w[0] = w0;

    ripemd160_ctx_t ctx0;

    ripemd160_init (&ctx0);

    ripemd160_update (&ctx0, w, pw_len);

    ripemd160_final (&ctx0);

    const u32 k0 = ctx0.h[0];
    const u32 k1 = ctx0.h[1];
    const u32 k2 = ctx0.h[2];
    const u32 k3 = ctx0.h[3];

    u32 k4 = 0, k5 = 0, k6 = 0, k7 = 0;

    if (serpent_key_len > 128)
    {
      k4 = ctx0.h[4];

      ripemd160_ctx_t ctx;

      ripemd160_init (&ctx);

      ctx.w0[0] = 0x00000041;

      ctx.len = 1;

      ripemd160_update (&ctx, w, pw_len);

      ripemd160_final (&ctx);

      k5 = ctx.h[0];

      if (serpent_key_len > 192)
      {
        k6 = ctx.h[1];
        k7 = ctx.h[2];
      }
    }

    // key

    u32 ukey[8] = { 0 };

    ukey[0] = k0;
    ukey[1] = k1;
    ukey[2] = k2;
    ukey[3] = k3;

    if (serpent_key_len > 128)
    {
      ukey[4] = k4;
      ukey[5] = k5;

      if (serpent_key_len > 192)
      {
        ukey[6] = k6;
        ukey[7] = k7;
      }
    }

    // IV

    const u32 iv[4] = {
      salt_bufs[SALT_POS_HOST].salt_buf[0],
      salt_bufs[SALT_POS_HOST].salt_buf[1],
      salt_bufs[SALT_POS_HOST].salt_buf[2],
      salt_bufs[SALT_POS_HOST].salt_buf[3]
    };

    // CT

    u32 CT[4] = { 0 };

    // serpent

    u32 ks[140] = { 0 };

    if (serpent_key_len == 128)
    {
      serpent128_set_key (ks, ukey);

      serpent128_encrypt (ks, iv, CT);
    }
    else if (serpent_key_len == 192)
    {
      serpent192_set_key (ks, ukey);

      serpent192_encrypt (ks, iv, CT);
    }
    else
    {
      serpent256_set_key (ks, ukey);

      serpent256_encrypt (ks, iv, CT);
    }

    const u32 r0 = hc_swap32_S (CT[0]);
    const u32 r1 = hc_swap32_S (CT[1]);
    const u32 r2 = hc_swap32_S (CT[2]);
    const u32 r3 = hc_swap32_S (CT[3]);

    COMPARE_S_SCALAR (r0, r1, r2, r3);
  }
}
