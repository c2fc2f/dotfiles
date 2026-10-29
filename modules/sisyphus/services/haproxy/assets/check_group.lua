core.register_action("check_group", { "http-req" }, function(txn)
  local req_group = txn:get_var("txn.required_group")
  local user_groups = txn:get_var("req.auth_response_header.x_auth_request_groups")

  local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
  end

  if req_group == nil or req_group == "" or trim(req_group) == "*" then
    txn:set_var("txn.group_authorized", true)
    return
  end

  req_group = trim(req_group)

  if user_groups == nil or user_groups == "" then
    core.Alert("Auth failed: User has no groups, but '" .. req_group .. "' is required.")
    txn:set_var("txn.group_authorized", false)
    return
  end

  local authorized = false
  for g in string.gmatch(user_groups, "([^,]+)") do
    local trimmed_g = trim(g)
    local short_name = trimmed_g:match("^([^@]+)@") or trimmed_g
    if trimmed_g == req_group or short_name == req_group then
      authorized = true
      break
    end
  end

  if not authorized then
    core.Alert("Auth failed: Access denied. Required: '" .. req_group .. "', User has: '" .. user_groups .. "'")
  end

  txn:set_var("txn.group_authorized", authorized)
end)
