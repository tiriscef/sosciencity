--- The gui called "The City Builder's Manual" that should provide a lot of information to the player.
Gui.CityView = {}

local get_subtbl = Tirislib.Tables.get_subtbl
local get_subtblr = Tirislib.Tables.get_subtbl_recursive

local CITY_VIEW_NAME = "sosciencity-city-view"

local header_icons = {
    "item-group/sosciencity-infrastructure",
    "item-group/sosciencity-production",
    "item/huwan-egg",
    "item/huwan-agender-egg",
    "item/huwan-fale-egg",
    "item/huwan-pachin-egg",
    "item/huwan-ga-egg",
    "item/lumber",
    "item/cloth",
    "item/architectural-concept",
    "item/necrofall",
    "item/boofish",
    "item/botanical-study",
    "item/invention",
    "item/complex-scientific-data",
    "item/glass",
    "item/artificial-limb",
    "technology/architecture-1",
    "recipe/gathering-materials",
    "recipe/gathering-food",
    "recipe/gathering-algae",
    "recipe/gathering-mushrooms"
}

local footer_variant_count = 4

--- The content of the city view. Is an array of categories, which contain a number of pages.
local content = {}

--- Adds a new category tab to the city view.
--- @param name string
--- @param localised_name locale
function Gui.CityView.add_category(name, localised_name)
    Tirislib.Utils.desync_protection()

    local index = #content + 1
    content[index] = {
        name = name,
        localised_name = localised_name,
        index = index,
        pages = {}
    }
end

--- Returns the definition of the category with the given name. Or nil if there is no category
--- with this name.
--- @param category_name string
--- @return table|nil
function Gui.CityView.get_category_definition(category_name)
    for _, category in pairs(content) do
        if category.name == category_name then
            return category
        end
    end
end

--- Adds a page definition to the given category.\
--- Page:\
---   [name]: string\
---   [category]: string (name of the category)\
---   [localised_name]: locale\
---   [creator]: function (takes the gui container as argument)\
---   [enabler]: function (returns a truthy/falsy value if the page should show up), optional
--- @param page table
function Gui.CityView.add_page(page)
    Tirislib.Utils.desync_protection()

    local category = Gui.CityView.get_category_definition(page.category)
    category.pages[#category.pages + 1] = page
end

--- Returns the page with the given name in the given categp
--- @param category table (a category definition)
--- @param page_name string
--- @return table|nil
function Gui.CityView.get_page_definition(category, page_name)
    for _, page in pairs(category.pages) do
        if page.name == page_name then
            return page
        end
    end
end

local function fill_menu(container, category_index, selected_page)
    local category = content[category_index]

    for _, page in pairs(content[category_index].pages) do
        if not page.enabler or page.enabler() then
            container.add {
                type = "button",
                name = page.name,
                caption = page.localised_name,
                tags = {
                    category = category.name,
                    page = page.name,
                    sosciencity_gui_event = "open_page"
                },
                style = page.name == selected_page and "sosciencity_city_view_page_button_selected" or
                    "sosciencity_city_view_page_button"
            }
        end
    end
end

local function open_page(player, category_index, page_name, set_tab_index)
    local category = content[category_index]
    local page = Gui.CityView.get_page_definition(category, page_name)
    if not page then
        return
    end

    local gui = player.gui.screen[CITY_VIEW_NAME]
    if not gui then
        return
    end
    local tab = gui.content.tabpane[category.name]

    local page_container = tab.page.scroll
    page_container.clear()
    page.creator(page_container)

    local menu = tab.menu.scroll
    menu.clear()
    fill_menu(menu, category_index, page_name)

    local last_opened_pages = get_subtblr(storage, "last_opened_pages", player.index)
    last_opened_pages[category_index] = page_name

    if set_tab_index then
        gui.content.tabpane.selected_tab_index = category_index
    end
end

Gui.set_click_handler_tag(
    "open_page",
    function(event)
        local player = game.get_player(event.player_index)
        local tags = event.element.tags
        local category = Gui.CityView.get_category_definition(tags.category)

        open_page(player, category.index, tags.page, true)
    end
)

local function create_city_view(player)
    local city_view_frame =
        player.gui.screen.add {
        type = "frame",
        name = CITY_VIEW_NAME,
        direction = "vertical",
        style = "sosciencity_city_view"
    }

    -- This triggers the on_gui_opened event upon which other mods might delete the city view, so we check if it's still there
    player.opened = city_view_frame
    if not city_view_frame.valid then
        return
    end

    local header =
        city_view_frame.add {
        type = "flow",
        name = "header",
        direction = "horizontal",
        style = "sosciencity_city_view_header_flow"
    }
    header.drag_target = city_view_frame

    for _ = 1, 3 do
        header.add {
            type = "sprite",
            sprite = header_icons[math.random(#header_icons)],
            ignored_by_interaction = true,
            style = "sosciencity_city_view_header_icon"
        }
    end

    header.add {
        type = "label",
        ignored_by_interaction = true,
        caption = {"city-view.the-city-builders-manual"},
        style = "frame_title"
    }
    header.add {
        type = "empty-widget",
        ignored_by_interaction = true,
        style = "sosciencity_city_view_header_drag"
    }
    header.add {
        type = "sprite-button",
        name = "sosciencity-close-city-view",
        sprite = "utility/close",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "close_button",
        tags = {
            sosciencity_gui_event = "toggle-city-view-opened"
        }
    }

    local content_frame =
        city_view_frame.add {
        type = "frame",
        name = "content",
        direction = "vertical",
        style = "sosciencity_city_view_tab_frame"
    }

    local content_tabpane =
        content_frame.add {
        type = "tabbed-pane",
        name = "tabpane"
    }

    local last_opened_pages = get_subtblr(storage, "last_opened_pages", player.index)

    for index, category in pairs(content) do
        local tab =
            content_tabpane.add {
            type = "tab",
            name = category.name .. "tab",
            caption = category.localised_name
        }

        local tab_flow =
            content_tabpane.add {
            type = "flow",
            name = category.name,
            direction = "horizontal",
            style = "sosciencity_city_view_tab_flow"
        }
        content_tabpane.add_tab(tab, tab_flow)

        local pages_frame =
            tab_flow.add {
            type = "frame",
            name = "menu",
            direction = "vertical",
            style = "inside_deep_frame"
        }
        pages_frame.add {
            type = "scroll-pane",
            name = "scroll",
            direction = "vertical",
            vertical_scroll_policy = "auto",
            style = "sosciencity_city_view_pages_scroll_pane"
        }

        local page_content_frame =
            tab_flow.add {
            type = "frame",
            name = "page",
            direction = "vertical",
            style = "inside_shallow_frame"
        }
        page_content_frame.add {
            type = "scroll-pane",
            name = "scroll",
            style = "sosciencity_city_view_page_content_scroll_pane"
        }

        open_page(player, index, last_opened_pages[index] or category.pages[1].name)
    end

    local last_opened_tab = get_subtbl(storage, "last_opened_tab")[player.index]
    if last_opened_tab then
        content_tabpane.selected_tab_index = last_opened_tab
    end

    local footer =
        city_view_frame.add {
        type = "flow",
        name = "footer",
        direction = "horizontal",
        style = "sosciencity_city_view_footer_flow"
    }
    footer.drag_target = city_view_frame
    footer.add {
        type = "empty-widget",
        ignored_by_interaction = true,
        style = "sosciencity_city_view_footer_drag"
    }
    footer.add {
        type = "label",
        ignored_by_interaction = true,
        caption = {"city-view.footer" .. math.random(footer_variant_count)},
        style = "sosciencity_city_view_footer_label"
    }

    city_view_frame.force_auto_center()
end

function Gui.CityView.close(player)
    local gui = player.gui.screen[CITY_VIEW_NAME]
    if gui then
        local last_opened_tab = get_subtbl(storage, "last_opened_tab")
        last_opened_tab[player.index] = gui.content.tabpane.selected_tab_index

        gui.destroy()
    end
end
local close_city_view = Gui.CityView.close

local function toggle_city_view_opened(player)
    local gui = player.gui.screen[CITY_VIEW_NAME]
    if gui then
        close_city_view(player)
    else
        create_city_view(player)
    end
end

Gui.set_click_handler_tag(
    "toggle-city-view-opened",
    function(event)
        toggle_city_view_opened(game.get_player(event.player_index))
    end
)
Gui.add_gui_closed_handler(
    function(player, event)
        local element = event.element
        if element and element.name == CITY_VIEW_NAME then
            close_city_view(player)
        end
    end
)

require("classes.guis.city-view-pages.report-pages")
require("classes.guis.city-view-pages.data-pages")
require("classes.guis.city-view-pages.howto-pages")
