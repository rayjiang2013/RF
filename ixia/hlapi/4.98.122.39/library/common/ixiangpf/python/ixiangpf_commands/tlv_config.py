# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def tlv_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    tlv_config
		
		 Description:
		    This command will create, modify or remove a TLV template or a TLV.
		
		 Synopsis:
		    tlv_config
		x       [-handle                        ANY]
		x       [-tlv_handle                    ANY]
		x       [-protocol                      CHOICES dhcp4_client
		x                                       CHOICES dhcp4_server
		x                                       CHOICES dhcp6_client
		x                                       CHOICES dhcp6_server
		x                                       CHOICES dhcp4_relay
		x                                       CHOICES dhcp6_relay
		x                                       CHOICES dhcp6_relay_light
		x                                       CHOICES ancp]
		x       -mode                           CHOICES create_template_group
		x                                       CHOICES create_tlv
		x                                       CHOICES create_tlv_container
		x                                       CHOICES create_field
		x                                       CHOICES modify
		x                                       CHOICES delete
		x                                       CHOICES delete_all
		x       [-template_group_name           ALPHA]
		x       [-container_name                ALPHA]
		x       [-container_description         ALPHA]
		x       [-container_is_required         CHOICES 0 1]
		x       [-container_is_editable         CHOICES 0 1]
		x       [-container_is_enabled          CHOICES 0 1]
		x       [-container_is_repeatable       CHOICES 0 1]
		x       [-tlv_name                      ALPHA]
		x       [-tlv_description               ALPHA]
		x       [-tlv_is_enabled                CHOICES 0 1]
		x       [-tlv_is_repeatable             CHOICES 0 1]
		x       [-tlv_is_required               CHOICES 0 1]
		x       [-tlv_is_editable               CHOICES 0 1]
		x       [-tlv_include_in_messages       ANY]
		x       [-clear_tlv_include_in_messages FLAG]
		x       [-tlv_enable_per_session        CHOICES 0 1]
		x       [-field_name                    ALPHA]
		x       [-field_description             ALPHA]
		x       [-field_encoding                CHOICES bool
		x                                       CHOICES decimal
		x                                       CHOICES fcid
		x                                       CHOICES hex
		x                                       CHOICES float
		x                                       CHOICES ipv4
		x                                       CHOICES ipv6
		x                                       CHOICES mac
		x                                       CHOICES string]
		x       [-field_size                    NUMERIC]
		x       [-field_value                   ALPHA]
		x       [-field_is_required             CHOICES 0 1]
		x       [-field_is_repeatable           CHOICES 0 1]
		x       [-field_is_enabled              CHOICES 0 1]
		x       [-field_is_editable             CHOICES 0 1]
		x       [-type_name                     ALPHA]
		x       [-type_is_editable              CHOICES 0 1]
		x       [-type_is_required              CHOICES 0 1]
		x       [-length_name                   ALPHA]
		x       [-length_description            ALPHA]
		x       [-length_encoding               CHOICES bool
		x                                       CHOICES decimal
		x                                       CHOICES fcid
		x                                       CHOICES hex
		x                                       CHOICES float
		x                                       CHOICES ipv4
		x                                       CHOICES ipv6
		x                                       CHOICES mac
		x                                       CHOICES string]
		x       [-length_size                   NUMERIC]
		x       [-length_value                  ALPHA]
		x       [-length_is_required            CHOICES 0 1]
		x       [-length_is_editable            CHOICES 0 1]
		x       [-length_is_enabled             CHOICES 0 1]
		x       [-disable_name_matching         FLAG]
		
		 Arguments:
		x   -handle
		x       The handle of a protocol stack or another handle returned by a prior tlv_config command.
		x   -tlv_handle
		x       The handle of a TLV from a default or custom TLV Template that will be used to define the structure of a new TLV that is added to the TLV Profile of a protocol.
		x   -protocol
		x       The type of protocol that the TLV applies to.
		x   -mode
		x       The action that the command will execute.
		x   -template_group_name
		x       When the -mode is create_template_group the value of this argument will be used to specify the name of the new TLV Template group. When the -mode is create_tlv the value of this argument will be used to find an existing TLV Template group with a matching name.
		x   -container_name
		x       The name of the container.
		x   -container_description
		x       The description of the container.
		x   -container_is_required
		x       Flag indicating whether the container is required in the TLV definition from the TLV Template.
		x   -container_is_editable
		x       Flag indicating whether the container is editable in the TLV definition from the TLV Template.
		x   -container_is_enabled
		x       Flag indicating whether the container is enabled or not in the TLV Profile of the protocol.
		x   -container_is_repeatable
		x       Indicates whether the new container can be multiplied in the TLV definition from the TLV Template.
		x   -tlv_name
		x       The name of the TLV or subTLV.
		x   -tlv_description
		x       The description of the TLV or subTLV.
		x   -tlv_is_enabled
		x       Flag indicating whether the TLV or subTLV is enabled in the TLV profile of a protocol.
		x   -tlv_is_repeatable
		x       Indicates whether the current TLV or subTLV can be multiplied in the TLV definition from the TLV Template.
		x   -tlv_is_required
		x       Indicates whether the current TLV or subTLV is required in the TLV definition from the TLV Template.
		x   -tlv_is_editable
		x       Indicates whether the current TLV or subTLV from a TLV Template is editable when added to the TLV Profile of a protocol.
		x   -tlv_include_in_messages
		x       Include the TLV in these protocol messages. Partial names of the messages can be used.
		x   -clear_tlv_include_in_messages
		x       Clear all protocol messages that the TLV should be included in.
		x   -tlv_enable_per_session
		x       Enable this TLV or subTLV per session.
		x   -field_name
		x       The name of the TLV field.
		x   -field_description
		x       The description of the TLV field.
		x   -field_encoding
		x       The encoding of the TLV field's value. Any change via this argument will result in the field's value being reset unless a matching value is specified for field_value.
		x   -field_size
		x       The size of the TLV field's value. Any change via this argument will result in the field's value being reset unless a matching value is specified for field_value.
		x   -field_value
		x       The value of the field. This can be a handle returned by multivalue_config.
		x   -field_is_required
		x       Flag indicating whether the field is required in the TLV definition from the TLV Template.
		x   -field_is_repeatable
		x       Flag indicating whether the field is repeatable in the TLV definition from the TLV Template.
		x   -field_is_enabled
		x       Enables/disables the field in the TLV Profile of a protocol.
		x   -field_is_editable
		x       Enables/disables editing for the field.
		x   -type_name
		x       The name of the TLV type.
		x   -type_is_editable
		x       Enables/disables editing for the type.
		x   -type_is_required
		x       Flag indicating whether the type is required in the TLV definition.
		x   -length_name
		x       The name of the TLV length.
		x   -length_description
		x       The description of the TLV length.
		x   -length_encoding
		x       The encoding of the TLV length's value. Any change via this argument will result in the length's value being reset unless a matching value is specified for length_value.
		x   -length_size
		x       The size of the TLV length's value. Any change via this argument will result in the length's value being reset unless a matching value is specified for length_value.
		x   -length_value
		x       The value of the length. This can be a handle returned by multivalue_config.
		x   -length_is_required
		x       Flag indicating whether the length is required in the TLV definition from the TLV Template.
		x   -length_is_editable
		x       Enables/disables editing for the length.
		x   -length_is_enabled
		x       Enables/disables the length from the TLV Profile of a protocol.
		x   -disable_name_matching
		x       This flag can be used to disable the name matching algorithm that attempts to look for a TLV template to copy when tlv_name and/or template_group_name are specified.
		
		 Return Values:
		    A list containing the tlv template group protocol stack handles that were added by the command (if any).
		x   key:tlv_template_group_handle  value:A list containing the tlv template group protocol stack handles that were added by the command (if any).
		    A list containing the tlv template protocol stack handles that were added by the command (if any).
		x   key:tlv_template_handle        value:A list containing the tlv template protocol stack handles that were added by the command (if any).
		    A list containing the tlv value protocol stack handles that were added by the command (if any).
		x   key:tlv_value_handle           value:A list containing the tlv value protocol stack handles that were added by the command (if any).
		    A list containing the subtlv template protocol stack handles that were added by the command (if any).
		x   key:subtlv_template_handle     value:A list containing the subtlv template protocol stack handles that were added by the command (if any).
		    A list containing the tlv field protocol stack handles that were added by the command (if any).
		x   key:tlv_field_handle           value:A list containing the tlv field protocol stack handles that were added by the command (if any).
		    A list containing the tlv container protocol stack handles that were added by the command (if any).
		x   key:tlv_container_handle       value:A list containing the tlv container protocol stack handles that were added by the command (if any).
		    A list containing the tlv type protocol stack handles that were added by the command (if any).
		x   key:tlv_type_handle            value:A list containing the tlv type protocol stack handles that were added by the command (if any).
		    A list containing the tlv length protocol stack handles that were added by the command (if any).
		x   key:tlv_length_handle          value:A list containing the tlv length protocol stack handles that were added by the command (if any).
		    A list containing the tlv protocol stack handles that were added by the command (if any).
		x   key:tlv_handle                 value:A list containing the tlv protocol stack handles that were added by the command (if any).
		    A list containing the default tlv protocol stack handles that were added by the command (if any).
		x   key:default_tlv_handle         value:A list containing the default tlv protocol stack handles that were added by the command (if any).
		    A list containing the subtlv protocol stack handles that were added by the command (if any).
		x   key:subtlv_handle              value:A list containing the subtlv protocol stack handles that were added by the command (if any).
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    When -handle is provided with the /globals value the command will configure a TLV template.
		
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
				'tlv_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
