tags = tags or {}

tags.MAX_NAME_LIMIT = 20
tags.MAX_VALUE_LIMIT = 2000
tags.MAX_USER_TAGS = 200

function tags.IsValidName(name)
    return string.match(name, "[^%w_]") == nil
end