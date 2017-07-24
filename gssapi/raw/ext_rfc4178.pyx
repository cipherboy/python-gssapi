from gssapi.raw.cython_types cimport *
from gssapi.raw.creds cimport Creds
from gssapi.raw.cython_converters cimport c_get_mech_oid_set
GSSAPI="BASE"  # This ensures that a full module is generated by Cython

from gssapi.raw.misc import GSSError

cdef extern from "python_gssapi_ext.h":
    OM_uint32 gss_set_neg_mechs(
        OM_uint32 *minor_status,
        gss_cred_id_t cred_handle,
        const gss_OID_set mech_set) nogil


def set_neg_mechs(Creds creds=None, mech_set=None):
    """
    set_neg_mechs(creds, mech_set)
    Specifies the set of mechanisms to be used for negotiation with the
    given credentials.

    Args:
        creds (Creds): Credentials; cannot be None
        mech_set ([OID]): Set of mechanisms to be negotiated

    Returns:
        bool: Success

    Raises:
        GSSError
    """
    cdef OM_uint32 maj_stat, min_stat
    cdef gss_cred_id_t cred_handle = NULL
    cdef gss_OID_set mechs = GSS_C_NO_OID_SET

    if creds is not None:
        cred_handle = creds.raw_creds

    if mech_set is not None:
        mechs = c_get_mech_oid_set(mech_set)

    with nogil:
        maj_stat = gss_set_neg_mechs(&min_stat, cred_handle, mechs)

    if maj_stat == GSS_S_COMPLETE:
        return True
    else:
        raise GSSError(maj_stat, min_stat)
