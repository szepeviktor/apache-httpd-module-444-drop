#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_core.h"
#include "http_log.h"
#include "http_request.h"
#include "util_filter.h"
#include "apr_buckets.h"

static apr_status_t mod444_out_filter(ap_filter_t *f, apr_bucket_brigade *bb)
{
    request_rec *r = f->r;

    if (r && r->status == 444) {
        if (r->connection) {
            r->connection->keepalive = AP_CONN_CLOSE;
            r->connection->aborted   = 1;
        }
        ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r,
                      "mod_444: dropping connection on status 444");
        ap_remove_output_filter(f);
        return APR_ECONNABORTED;
    }

    return ap_pass_brigade(f->next, bb);
}

static void mod444_insert_filter(request_rec *r)
{
    ap_add_output_filter("MOD444_OUT", NULL, r, r->connection);
}

static void mod444_register_hooks(apr_pool_t *p)
{
    ap_register_output_filter("MOD444_OUT", mod444_out_filter, NULL, AP_FTYPE_PROTOCOL);
    ap_hook_insert_filter(mod444_insert_filter, NULL, NULL, APR_HOOK_MIDDLE);
}

module AP_MODULE_DECLARE_DATA fourfour_module =
{
    STANDARD20_MODULE_STUFF,
    NULL, NULL, NULL, NULL, NULL,
    mod444_register_hooks
};
