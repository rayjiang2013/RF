# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def traffic_tag_config(self, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    traffic_tag_config
		
		 Description:
		    This method is used to configure traffic tag for a protocol stack
		
		 Synopsis:
		    traffic_tag_config
		x       [-handle  ANY]
		        [-mode    CHOICES create modify delete
		                  DEFAULT create]
		x       [-enabled CHOICES 0 1]
		x       [-name    ALPHA]
		x       [-id      NUMERIC]
		
		 Arguments:
		x   -handle
		x       For create: protocol stack handle needed to configure traffic tag.
		x       For modify/delete: tag handle that must be modified/deleted
		    -mode
		        Which mode is being performed.
		x   -enabled
		x       Enables/disables tags
		x   -name
		x       specifies the name of the tag the entity will be part of
		x   -id
		x       the tag ids that this entity will use/publish
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status              value:$::SUCCESS | $::FAILURE
		    On status of failure, gives detailed information.
		    key:log                 value:On status of failure, gives detailed information.
		    A handle that can be used to modify/delete the tag
		    key:traffic_tag_handle  value:A handle that can be used to modify/delete the tag
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		
		 See Also:
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = []
		mandatory_params = []
		file_params = []

		try:
			return self.__execute_command(
				'traffic_tag_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
