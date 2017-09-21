/* Avalon Plug 'N Play ROM definitions */

/* Note that for backwards compatibility new structure versions should include
 * the members of the previous version */

#ifndef _avalon_pnp_h_
#define _avalon_pnp_h_

#ifdef __cplusplus
extern "C" {
#endif

/* includes */

#include <stdint.h>
#include <lstLib.h>

/* types */

/* generic Avalon capability list node */
typedef struct
	{
	NODE		*next;		/* next node */
	NODE		*previous;	/* previous node */
	uint16_t	capId;		/* capability ID */                  
	uint8_t		ver;		/* capability version */
	void		*cap;		/* pointer to specific capability */
	} avalonCapNode_t;
    
/* generic Avalon interface list node */
typedef struct
	{
	NODE		*next;		/* next node */
	NODE		*previous;	/* previous node */
	uint16_t	intfType;	/* interface type */                  
	uint8_t		ver;		/* interface version */
	void		*intf;		/* pointer to specific interface */
	} avalonIntfNode_t;
    
/* Avalon device ID capability (capId = 1, ver = 1)*/
typedef struct
	{
	char		*devName;	/* device name string */
	char		*partNum;	/* device part number string */
	uint16_t	*gwVer;		/* gateware version */
	} avalonDevIdCap_t;
	
/* Avalon device ID capability (capId = 1, ver = 2)*/
typedef struct
	{
	char		*devName;	/* device name string */
	char		*partNum;	/* device part number string */
	uint16_t	*gwVer;		/* gateware version */
	uint32_t    *gitCommit; /* git commit number */
	int32_t     *buildId;   /* build id (UNIX time) */
	} avalonDevIdCap2_t;
	
/* Avalon IP ID capability (capID = 2) */
typedef struct
	{
	char		*modKind;	/* module kind string */
	char		*modName;	/* module name string */
	char		*modVer;	/* module version string */
	LIST   		masterIntfList;	/* master/receiver interface list */
	} avalonIpIdCap_t;

/* Avalon master interface (intfType = 1) */
typedef struct
	{
	char		*masterName;	/* master name string */
	LIST		slaveIntfList;	/* slave interface list */
	uint8_t		busWidth;	/* master bus width (bytes) */
	uint8_t		burstCount;	/* master burst count (bytes) */
	} avalonMasterIntf_t;
	
/* Avalon slave interface (intfType = 2) */
typedef struct
	{
	char		*slaveName;	/* slave name string */
	char		*modName;	/* module name string */
	uint64_t	baseAddr;	/* base address */
	uint64_t	addrSpan;	/* address span */
	uint8_t		busWidth;	/* slave bus width (bytes) */
	uint8_t		burstCount;	/* slave burst count (bytes) */
	} avalonSlaveIntf_t;
	
/* Avalon interrupt receiver interface (intfType = 3) */
typedef struct
	{
	char		*intRecvName;	/* interrupt receiver name string */
	LIST		intSendList;	/* interrupt sender list */
	} avalonIntRecvIntf_t;

/* Avalon interrupt sender interface (intfType = 4) */
typedef struct
	{
	char		*intSendName;	/* interrupt sender name string */
	char		*modName;	/* sender module name string */
	uint8_t		irq;		/* IRQ number */
	} avalonIntSendIntf_t;
 
#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _avalon_pnp_h_ */ 
