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

local content = {
    {
        name = "statistics",
        localised_name = {"sosciencity.statistics"},
        pages = {
            {
                name = "healthcare_report",
                localised_name = "testpage",
                creator = function(container)
                    container.add {
                        type = "label",
                        caption = "this is a test"
                    }
                    container.add {
                        type = "sprite",
                        sprite = header_icons[math.random(#header_icons)]
                    }
                end
            },
            {
                name = "testpage2",
                localised_name = "testpage 2 u know",
                creator = function(container)
                    container.add {
                        type = "label",
                        caption = "this is a second test"
                    }
                end
            }
        }
    },
    {
        name = "data",
        localised_name = {"sosciencity.data"},
        pages = {
            {
                name = "healthcare_report",
                localised_name = {"sosciencity.health"},
                creator = function(container)
                    container.add {
                        type = "label",
                        caption = "this is a test"
                    }
                end
            }
        }
    },
    {
        name = "how-tos",
        localised_name = {"sosciencity.how-tos"},
        pages = {
            {
                name = "healthcare_report",
                localised_name = {"sosciencity.health"},
                creator = function(container)
                    container.add {
                        type = "label",
                        caption = "this is a test"
                    }
                end
            }
        }
    }
}

local function get_category_definition(category_name)
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
---   [creator]: function (takes the gui container as argument)
--- @param page table
function Gui.CityView.add_page(page)
    Tirislib.Utils.desync_protection()

    local category = get_category_definition(page.category)
    category.pages[#category.pages + 1] = page
end

local function get_page_definition(category, page_name)
    for _, page in pairs(category.pages) do
        if page.name == page_name then
            return page
        end
    end
end

local function fill_menu(container, category_index, selected_page)
    for _, page in pairs(content[category_index].pages) do
        container.add {
            type = "button",
            name = page.name,
            caption = page.localised_name,
            tags = {
                category = category_index,
                page = page.name,
                sosciencity_gui_event = "open_page"
            },
            style = page.name == selected_page and "sosciencity_city_view_page_button_selected" or
                "sosciencity_city_view_page_button"
        }
    end
end

local function open_page(player, category_index, page_name)
    local category = content[category_index]
    local page = get_page_definition(category, page_name)
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

    local last_opened_pages = get_subtblr(global, "last_opened_pages", player.index)
    last_opened_pages[category_index] = page_name
end

Gui.set_click_handler_tag(
    "open_page",
    function(event)
        local player = game.players[event.player_index]
        local tags = event.element.tags

        open_page(player, tags.category, tags.page)
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
        caption = {"sosciencity.the-city-builders-manual"},
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
        sprite = "utility/close_white",
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

    local last_opened_pages = get_subtblr(global, "last_opened_pages", player.index)

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

    local last_opened_tab = get_subtbl(global, "last_opened_tab")[player.index]
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
        caption = {"sosciencity.footer" .. math.random(footer_variant_count)},
        style = "sosciencity_city_view_footer_label"
    }

    city_view_frame.force_auto_center()
end

local function close_city_view(player)
    local gui = player.gui.screen[CITY_VIEW_NAME]
    if gui then
        local last_opened_tab = get_subtbl(global, "last_opened_tab")
        last_opened_tab[player.index] = gui.content.tabpane.selected_tab_index

        gui.destroy()
    end
end

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
        toggle_city_view_opened(game.players[event.player_index])
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
