-- I don't feel like littering all my code with checks if needed feature flags are present.
-- So this is an attempt to clean up prototypes in the case that the feature flags are not enabled.
-- And not caring in the rest of my code.

if not feature_flags["spoiling"] then
    for _, item in Tirislib.Item.iterate() do
        if item.owner == "sosciencity" then
            item.spoil_ticks = nil
            item.spoil_result = nil
            item.spoil_to_trigger_result = nil
        end
    end
end
