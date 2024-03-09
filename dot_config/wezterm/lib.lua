return {
  isUnix = function()
    return package.config:sub(1, 1) == "/"
  end
}
