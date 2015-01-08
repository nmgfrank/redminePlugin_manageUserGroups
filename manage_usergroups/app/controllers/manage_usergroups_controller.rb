class ManageUsergroupsController < ApplicationController
  unloadable
  
   helper :groups
  include GroupsHelper  
  
  def update 
    group_id = params[:id]
    
    manager_ids_str = params[:manager_ids_str]
    manager_num = params[:manager_num]
    
    manager_num = manager_num.to_i
    manager_ids_array = manager_ids_str.split(",")
    
    if manager_ids_array.length < manager_num
        render :text => "0"
        return
    end
    
    # get selected manager ids
    manager_ids = []    
    manager_ids_array.each do |id_str|
        manager_ids.push(id_str.to_i)
    end
    
    # set old manager ids
    old_manager_ids = []
    manager_info = ManageUsergroups.where(["group_id = ?",group_id])
    manager_info.each do |manager_rela|
        old_manager_ids.push(manager_rela.manager_id.to_i)
    end
    
    to_add_ids = manager_ids - old_manager_ids
    to_delete_ids = old_manager_ids -  manager_ids
    
    # insert new manager ids
    to_add_ids.each do |id|
        manager_usergroup = ManageUsergroups.new
        
        manager_usergroup.group_id = group_id
        manager_usergroup.manager_id = id
        
        manager_usergroup.save
    
    end
    
    
    # delete valid manager ids
    manager_info.each do |manager_rela|
        if to_delete_ids.include? manager_rela.manager_id.to_i
            manager_rela.destroy
        end
    end
    
    
    render :text => manager_ids.to_s
    return
  
  end
  
  
  def index
  
    managergroup_info = ManageUsergroups.where(["manager_id = ?",User.current.id])
    
    @group_list = []
    
    managergroup_info.each do |managergroup|
        group_id = managergroup.group_id
        
        group = Group.find(group_id)
        
        if !group.nil?
            @group_list.push(group) 
        end
    end
  end
  
  def edit 
    @group = Group.find(params[:id])
  end
  
  
  def autocomplete_for_user
    @group = Group.find(params[:id])
    
    managergroup_info = ManageUsergroups.where(["manager_id = ?",User.current.id])
  
  
    respond_to do |format|
      format.js
    end
  end
  
  
  def add_users
    @group = Group.find(params[:id])
    
    is_manager = false
    managergroup_info = ManageUsergroups.where(["manager_id = ?",User.current.id])
    managergroup_info.each do |managergroup|
        group_id = managergroup.group_id
        if group_id.to_i == @group.id.to_i
            is_manager = true
        end
    end

    if is_manager == true
        @users = User.find_all_by_id(params[:user_id] || params[:user_ids])
        @group.users << @users if request.post? && !@users.blank?
        @group.save
    end    
    redirect_to :action=>'edit', :id=>@group.id
  end  
  
  def delete_user
    @group = Group.find(params[:id])
    
    is_manager = false
    managergroup_info = ManageUsergroups.where(["manager_id = ?",User.current.id])
    managergroup_info.each do |managergroup|
        group_id = managergroup.group_id
        if group_id.to_i == @group.id.to_i
            is_manager = true
        end
    end
    
    if is_manager == true
        @group.users.delete(User.find(params[:user_id])) if request.delete?
    end
    
    redirect_to :action=>'edit', :id=>@group.id
  end  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
end
