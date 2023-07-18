//
//  Header.h
//  
//
//  Created by kintan on 2023/7/18.
//

#ifndef openssl_shim_h
#define openssl_shim_h
//#import <Libssl/openssl/ssl.h>
typedef struct ossl_init_settings_st OPENSSL_INIT_SETTINGS;
int OPENSSL_init_ssl(uint64_t opts, const OPENSSL_INIT_SETTINGS *settings);
int SSL_library_init() {
    return OPENSSL_init_ssl(0, NULL);
}

#endif /* openssl_shim_h */
