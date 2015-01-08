require_dependency 'groups_helper'

module ManageUsergroupsM
    module GroupsHelperPatch
        def self.included(base)
            base.send(:include, InstanceMethods)
            base.class_eval do 
                    
            end
        end

        module InstanceMethods

              def manage_usergroups_render_principals_for_new_group_users(group)
                scope = User.active.sorted.not_in_group(group).like(params[:q])
                principal_count = scope.count
                principal_pages = Redmine::Pagination::Paginator.new principal_count, 100, params['page']
                principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).all

                s = content_tag('div', principals_check_box_tags('user_ids[]', principals), :id => 'principals')
                links = pagination_links_full(principal_pages, principal_count, :per_page_links => false) {|text, parameters, options|
                  link_to text, autocomplete_for_user_group_path(group, parameters.merge(:q => params[:q], :format => 'js')), :remote => true
                }

                s 
              end
        end
    end
end

GroupsHelper.send(:include, ManageUsergroupsM::GroupsHelperPatch)
