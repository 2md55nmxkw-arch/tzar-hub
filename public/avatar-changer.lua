local SOURCE_URL = "https://hub.2md.space/avatar-changer.lua"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
if not game:IsLoaded() then
	game.Loaded:Wait()
end
local lp = Players.LocalPlayer
while not lp do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	lp = Players.LocalPlayer
end

local genv = getgenv and getgenv() or _G
if genv.AvatarChanger then pcall(genv.AvatarChanger.Destroy) end

local AC = {
	alive = true,
	conns = {},
	useRules = true,
	persist = true,
	source = nil,
	expect = {},
	originals = setmetatable({}, { __mode = "k" }),
	appliedChar = nil,
	busy = false,
}
genv.AvatarChanger = AC


local LANGS = {
	{ "ru", "Русский" },
	{ "en", "English" },
	{ "uk", "Українська" },
	{ "es", "Español" },
	{ "pt", "Português" },
	{ "de", "Deutsch" },
}

local function slavicPlural(one, few, many)
	return function(n)
		local m10, m100 = n % 10, n % 100
		local w = many
		if m10 == 1 and m100 ~= 11 then
			w = one
		elseif m10 >= 2 and m10 <= 4 and (m100 < 12 or m100 > 14) then
			w = few
		end
		return n .. " " .. w
	end
end

local function simplePlural(one, many)
	return function(n)
		return n .. " " .. (n == 1 and one or many)
	end
end

local STR = {
	ru = {
		err_generic = "Ошибка: %s",
		note_bundle = "тело из бандла %s",
		note_noappearance = "в игре выключен LoadCharacterAppearance",
		note_stdanims = "стандартные анимации",
		note_acc_scaled = "%s уменьшен x%.2f",
		note_acc_removed = "%s убран (размер)",
		rig_mismatch = "Риг не совпадает, а описания аватара нет",
		applied = "Применено: %s [%s]",
		rules_notes = "Правила игры: %s",
		enter_name = "Введи ник или UserId",
		player_not_found = "Игрок не найден: %s",
		loading_avatar = "Загружаю аватар %s...",
		avatar_failed = "Не удалось получить аватар: %s",
		no_character_of = "%s: нет персонажа",
		as_on_server = "как на сервере",
		reset_done = "Вернул исходный вид",
		export_done = "Скрипт образа %s скопирован в буфер и сохранён в workspace/%s. Закинь его в autoexec.",
		export_saved_only = "Скрипт образа %s сохранён в workspace/%s. Закинь его в autoexec.",
		script_hint = "Положи этот файл в папку autoexec своего исполнителя.",
		script_missing = "не удалось загрузить Avatar Changer",
		no_character = "Нет персонажа",
		outfit_default = "образ",
		emote_r15 = "Эмоции Roblox работают только на R15",
		emote_load_failed = "Не удалось загрузить эмоцию %s",
		asset_missing = "Нет такого ассета: %s",
		not_emote = "«%s» — это не эмоция",
		ready = "Готов. RightShift — скрыть или показать окно.",
		toast_success = "ГОТОВО",
		toast_error = "ОШИБКА",
		toast_now = "СЕЙЧАС",
		tab_look = "Образ",
		tab_emotes = "Эмоции",
		by_nick = "ПО НИКУ · ВИДНО ТОЛЬКО ТЕБЕ",
		nick_placeholder = "Ник или UserID",
		wear = "Надеть",
		reset_look = "Вернуть мой вид",
		on_server = "НА СЕРВЕРЕ",
		outfits = "ОБРАЗЫ",
		save = "Сохранить",
		after_death = "После смерти",
		game_rules = "Правила игры",
		my_look = "Мой образ",
		menu_as_server = "Как на сервере",
		menu_profile = "С профиля",
		menu_export = "Экспорт в autoexec",
		rmb_menu = "ПКМ — меню",
		players = slavicPlural("ИГРОК", "ИГРОКА", "ИГРОКОВ"),
		nothing_to_save = "Нечего сохранять: нет персонажа",
		saved_outfit = "Сохранил образ «%s»",
		deleted_outfit = "Удалил образ «%s»",
		meta_original = "ОРИГИНАЛ",
		meta_copied = "СКОПИРОВАН",
		meta_saved = "СОХРАНЁН",
		menu_wear = "Надеть",
		menu_rename = "Переименовать",
		menu_delete = "Удалить",
		emote_wheel = "КОЛЕСО ЭМОЦИЙ",
		reset = "Сбросить",
		empty_slot = "Пустой слот",
		menu_play = "Проиграть",
		menu_to_slot = "В слот %d",
		menu_clear = "Очистить",
		emote_search = "Поиск эмоций в каталоге",
		emote_saved = "«%s» теперь в слоте %d",
		from_outfit = "Из образа",
		own_wheel = "Своё колесо",
		emote_hint = "КЛАВИША «.» · ТОЛЬКО R15 · ВИДНО ВСЕМ",
		wheel_reset = "Колесо снова берёт эмоции из образа",
		empty = "пусто",
		wheel_title = "Эмоции",
		wheel_empty = "Пусто",
		sort_popular = "Популярные",
		sort_favorited = "Избранные",
		sort_new = "Новые",
		search_nothing = "Ничего не найдено",
		search_failed = "Каталог не ответил",
		slot_target = "В СЛОТ %d",
		emote_added = "«%s» добавлена в колесо",
		emote_removed = "«%s» убрана из колеса",
		emote_exists = "«%s» уже в колесе",
		menu_add_wheel = "Добавить в колесо",
		menu_front = "В начало",
		menu_remove = "Убрать",
		menu_wear_save = "Надеть и сохранить",
		tag_outfit = "ОБРАЗ",
		add = "Добавить",
		find = "Найти",
		open_wheel = "Открыть колесо",
		wheel_count = "КОЛЕСО ЭМОЦИЙ · %d",
		wheel_keys = "«.» — КОЛЕСО · Q / E — СТРАНИЦЫ · R15",
		side_emotes = "КАТАЛОГ ЭМОЦИЙ",
		side_avatars = "АВАТАРЫ",
		mode_players = "Игроки",
		mode_saved = "Мои",
		settings = "Настройки",
		settings_title = "НАСТРОЙКИ",
		intro_anim = "Интро-анимация",
		discord_notif = "Уведомление Discord",
		discord_text = "Заходи в Discord TZAR Hub — обновления, новые скрипты и поддержка.",
		copy_link = "Скопировать ссылку",
		dont_show = "Не показывать",
		link_copied = "Ссылка на Discord скопирована",
		settings_hint = "Интро и уведомление Discord можно выключить в настройках (шестерёнка сверху).",
		mode_catalog = "Каталог",
		avatar_search = "Ник игрока или название",
		type_nick = "Начни вводить ник",
		wheel_search = "Поиск эмоций…",
		wheel_search_title = "Поиск",
		wheel_hint_search = "ЛКМ — ИГРАТЬ · ПКМ — В КОЛЕСО",
		language = "Язык",
	},
	en = {
		err_generic = "Error: %s",
		note_bundle = "body from bundle %s",
		note_noappearance = "LoadCharacterAppearance is off in this game",
		note_stdanims = "default animations",
		note_acc_scaled = "%s scaled x%.2f",
		note_acc_removed = "%s removed (size)",
		rig_mismatch = "Rig doesn't match and there's no avatar description",
		applied = "Applied: %s [%s]",
		rules_notes = "Game rules: %s",
		enter_name = "Enter a username or UserId",
		player_not_found = "Player not found: %s",
		loading_avatar = "Loading %s's avatar...",
		avatar_failed = "Couldn't load the avatar: %s",
		no_character_of = "%s has no character",
		as_on_server = "as on server",
		reset_done = "Back to your own look",
		export_done = "Outfit script for %s copied to clipboard and saved to workspace/%s. Drop it into autoexec.",
		export_saved_only = "Outfit script for %s saved to workspace/%s. Drop it into autoexec.",
		script_hint = "Put this file into your executor's autoexec folder.",
		script_missing = "couldn't load Avatar Changer",
		no_character = "No character",
		outfit_default = "outfit",
		emote_r15 = "Roblox emotes only work on R15",
		emote_load_failed = "Couldn't load emote %s",
		asset_missing = "No such asset: %s",
		not_emote = "“%s” is not an emote",
		ready = "Ready. RightShift hides or shows the window.",
		toast_success = "DONE",
		toast_error = "ERROR",
		toast_now = "NOW",
		tab_look = "Outfit",
		tab_emotes = "Emotes",
		by_nick = "BY USERNAME · ONLY YOU SEE IT",
		nick_placeholder = "Username or user ID",
		wear = "Wear",
		reset_look = "Reset to mine",
		on_server = "IN THIS SERVER",
		outfits = "OUTFITS",
		save = "Save",
		after_death = "Keep on respawn",
		game_rules = "Game rules",
		my_look = "My look",
		menu_as_server = "As in this server",
		menu_profile = "From profile",
		menu_export = "Export to autoexec",
		rmb_menu = "RMB — menu",
		players = simplePlural("PLAYER", "PLAYERS"),
		nothing_to_save = "Nothing to save: no character",
		saved_outfit = "Saved outfit “%s”",
		deleted_outfit = "Deleted outfit “%s”",
		meta_original = "ORIGINAL",
		meta_copied = "COPIED",
		meta_saved = "SAVED",
		menu_wear = "Wear",
		menu_rename = "Rename",
		menu_delete = "Delete",
		emote_wheel = "EMOTE WHEEL",
		reset = "Reset",
		empty_slot = "Empty slot",
		menu_play = "Play",
		menu_to_slot = "To slot %d",
		menu_clear = "Clear",
		emote_search = "Search emotes in catalog",
		emote_saved = "“%s” is now in slot %d",
		from_outfit = "From outfit",
		own_wheel = "Custom wheel",
		emote_hint = "KEY “.” · R15 ONLY · EVERYONE SEES IT",
		wheel_reset = "The wheel uses the outfit's emotes again",
		empty = "empty",
		wheel_title = "Emotes",
		wheel_empty = "Empty",
		sort_popular = "Popular",
		sort_favorited = "Favorited",
		sort_new = "New",
		search_nothing = "Nothing found",
		search_failed = "Catalog didn't respond",
		slot_target = "TO SLOT %d",
		emote_added = "“%s” added to the wheel",
		emote_removed = "“%s” removed from the wheel",
		emote_exists = "“%s” is already in the wheel",
		menu_add_wheel = "Add to wheel",
		menu_front = "Move to front",
		menu_remove = "Remove",
		menu_wear_save = "Wear and save",
		tag_outfit = "OUTFIT",
		add = "Add",
		find = "Find",
		open_wheel = "Open wheel",
		wheel_count = "EMOTE WHEEL · %d",
		wheel_keys = "“.” — WHEEL · Q / E — PAGES · R15",
		side_emotes = "EMOTE CATALOG",
		side_avatars = "AVATARS",
		mode_players = "Players",
		mode_saved = "Saved",
		settings = "Settings",
		settings_title = "SETTINGS",
		intro_anim = "Intro animation",
		discord_notif = "Discord notification",
		discord_text = "Join the TZAR Hub Discord — updates, new scripts and support.",
		copy_link = "Copy link",
		dont_show = "Don't show",
		link_copied = "Discord link copied",
		settings_hint = "The intro and the Discord notification can be turned off in settings (gear at the top).",
		mode_catalog = "Catalog",
		avatar_search = "Username or bundle name",
		type_nick = "Start typing a username",
		wheel_search = "Search emotes…",
		wheel_search_title = "Search",
		wheel_hint_search = "LMB — PLAY · RMB — ADD",
		language = "Language",
	},
	uk = {
		err_generic = "Помилка: %s",
		note_bundle = "тіло з бандла %s",
		note_noappearance = "у грі вимкнено LoadCharacterAppearance",
		note_stdanims = "стандартні анімації",
		note_acc_scaled = "%s зменшено x%.2f",
		note_acc_removed = "%s прибрано (розмір)",
		rig_mismatch = "Риг не збігається, а опису аватара немає",
		applied = "Застосовано: %s [%s]",
		rules_notes = "Правила гри: %s",
		enter_name = "Введи нік або UserId",
		player_not_found = "Гравця не знайдено: %s",
		loading_avatar = "Завантажую аватар %s...",
		avatar_failed = "Не вдалося отримати аватар: %s",
		no_character_of = "%s: немає персонажа",
		as_on_server = "як на сервері",
		reset_done = "Повернув твій вигляд",
		export_done = "Скрипт образу %s скопійовано в буфер і збережено в workspace/%s. Кинь його в autoexec.",
		export_saved_only = "Скрипт образу %s збережено в workspace/%s. Кинь його в autoexec.",
		script_hint = "Поклади цей файл у папку autoexec свого виконавця.",
		script_missing = "не вдалося завантажити Avatar Changer",
		no_character = "Немає персонажа",
		outfit_default = "образ",
		emote_r15 = "Емоції Roblox працюють лише на R15",
		emote_load_failed = "Не вдалося завантажити емоцію %s",
		asset_missing = "Немає такого ассета: %s",
		not_emote = "«%s» — це не емоція",
		ready = "Готово. RightShift — сховати або показати вікно.",
		toast_success = "ГОТОВО",
		toast_error = "ПОМИЛКА",
		toast_now = "ЗАРАЗ",
		tab_look = "Образ",
		tab_emotes = "Емоції",
		by_nick = "ЗА НІКОМ · БАЧИШ ЛИШЕ ТИ",
		nick_placeholder = "Нік або UserID",
		wear = "Вдягнути",
		reset_look = "Мій вигляд",
		on_server = "НА СЕРВЕРІ",
		outfits = "ОБРАЗИ",
		save = "Зберегти",
		after_death = "Після смерті",
		game_rules = "Правила гри",
		my_look = "Мій образ",
		menu_as_server = "Як на сервері",
		menu_profile = "З профілю",
		menu_export = "Експорт в autoexec",
		rmb_menu = "ПКМ — меню",
		players = slavicPlural("ГРАВЕЦЬ", "ГРАВЦІ", "ГРАВЦІВ"),
		nothing_to_save = "Нічого зберігати: немає персонажа",
		saved_outfit = "Зберіг образ «%s»",
		deleted_outfit = "Видалив образ «%s»",
		meta_original = "ОРИГІНАЛ",
		meta_copied = "СКОПІЙОВАНО",
		meta_saved = "ЗБЕРЕЖЕНО",
		menu_wear = "Вдягнути",
		menu_rename = "Перейменувати",
		menu_delete = "Видалити",
		emote_wheel = "КОЛЕСО ЕМОЦІЙ",
		reset = "Скинути",
		empty_slot = "Порожній слот",
		menu_play = "Програти",
		menu_to_slot = "У слот %d",
		menu_clear = "Очистити",
		emote_search = "Пошук емоцій у каталозі",
		emote_saved = "«%s» тепер у слоті %d",
		from_outfit = "З образу",
		own_wheel = "Своє колесо",
		emote_hint = "КЛАВІША «.» · ЛИШЕ R15 · БАЧАТЬ УСІ",
		wheel_reset = "Колесо знову бере емоції з образу",
		empty = "порожньо",
		wheel_title = "Емоції",
		wheel_empty = "Порожньо",
		sort_popular = "Популярні",
		sort_favorited = "Улюблені",
		sort_new = "Нові",
		search_nothing = "Нічого не знайдено",
		search_failed = "Каталог не відповів",
		slot_target = "У СЛОТ %d",
		emote_added = "«%s» додано в колесо",
		emote_removed = "«%s» прибрано з колеса",
		emote_exists = "«%s» вже в колесі",
		menu_add_wheel = "Додати в колесо",
		menu_front = "На початок",
		menu_remove = "Прибрати",
		menu_wear_save = "Вдягнути й зберегти",
		tag_outfit = "ОБРАЗ",
		add = "Додати",
		find = "Знайти",
		open_wheel = "Відкрити колесо",
		wheel_count = "КОЛЕСО ЕМОЦІЙ · %d",
		wheel_keys = "«.» — КОЛЕСО · Q / E — СТОРІНКИ · R15",
		side_emotes = "КАТАЛОГ ЕМОЦІЙ",
		side_avatars = "АВАТАРИ",
		mode_players = "Гравці",
		mode_saved = "Мої",
		settings = "Налаштування",
		settings_title = "НАЛАШТУВАННЯ",
		intro_anim = "Інтро-анімація",
		discord_notif = "Сповіщення Discord",
		discord_text = "Заходь у Discord TZAR Hub — оновлення, нові скрипти й підтримка.",
		copy_link = "Скопіювати посилання",
		dont_show = "Не показувати",
		link_copied = "Посилання на Discord скопійовано",
		settings_hint = "Інтро та сповіщення Discord можна вимкнути в налаштуваннях (шестерня зверху).",
		mode_catalog = "Каталог",
		avatar_search = "Нік гравця або назва",
		type_nick = "Почни вводити нік",
		wheel_search = "Пошук емоцій…",
		wheel_search_title = "Пошук",
		wheel_hint_search = "ЛКМ — ГРАТИ · ПКМ — У КОЛЕСО",
		language = "Мова",
	},
	es = {
		err_generic = "Error: %s",
		note_bundle = "cuerpo del paquete %s",
		note_noappearance = "LoadCharacterAppearance está desactivado en este juego",
		note_stdanims = "animaciones estándar",
		note_acc_scaled = "%s reducido x%.2f",
		note_acc_removed = "%s quitado (tamaño)",
		rig_mismatch = "El rig no coincide y no hay descripción del avatar",
		applied = "Aplicado: %s [%s]",
		rules_notes = "Reglas del juego: %s",
		enter_name = "Escribe un usuario o UserId",
		player_not_found = "Jugador no encontrado: %s",
		loading_avatar = "Cargando el avatar de %s...",
		avatar_failed = "No se pudo cargar el avatar: %s",
		no_character_of = "%s no tiene personaje",
		as_on_server = "como en el servidor",
		reset_done = "Volviste a tu aspecto",
		export_done = "Script del atuendo %s copiado al portapapeles y guardado en workspace/%s. Ponlo en autoexec.",
		export_saved_only = "Script del atuendo %s guardado en workspace/%s. Ponlo en autoexec.",
		script_hint = "Pon este archivo en la carpeta autoexec de tu ejecutor.",
		script_missing = "no se pudo cargar Avatar Changer",
		no_character = "Sin personaje",
		outfit_default = "atuendo",
		emote_r15 = "Los emotes de Roblox solo funcionan en R15",
		emote_load_failed = "No se pudo cargar el emote %s",
		asset_missing = "No existe el asset: %s",
		not_emote = "«%s» no es un emote",
		ready = "Listo. RightShift oculta o muestra la ventana.",
		toast_success = "LISTO",
		toast_error = "ERROR",
		toast_now = "AHORA",
		tab_look = "Atuendo",
		tab_emotes = "Emotes",
		by_nick = "POR USUARIO · SOLO TÚ LO VES",
		nick_placeholder = "Usuario o ID",
		wear = "Poner",
		reset_look = "Volver al mío",
		on_server = "EN EL SERVIDOR",
		outfits = "ATUENDOS",
		save = "Guardar",
		after_death = "Tras morir",
		game_rules = "Reglas",
		my_look = "Mi aspecto",
		menu_as_server = "Como en el servidor",
		menu_profile = "Del perfil",
		menu_export = "Exportar a autoexec",
		rmb_menu = "Clic der. — menú",
		players = simplePlural("JUGADOR", "JUGADORES"),
		nothing_to_save = "Nada que guardar: sin personaje",
		saved_outfit = "Atuendo «%s» guardado",
		deleted_outfit = "Atuendo «%s» eliminado",
		meta_original = "ORIGINAL",
		meta_copied = "COPIADO",
		meta_saved = "GUARDADO",
		menu_wear = "Poner",
		menu_rename = "Renombrar",
		menu_delete = "Eliminar",
		emote_wheel = "RUEDA DE EMOTES",
		reset = "Restablecer",
		empty_slot = "Ranura vacía",
		menu_play = "Reproducir",
		menu_to_slot = "A la ranura %d",
		menu_clear = "Vaciar",
		emote_search = "Buscar emotes en el catálogo",
		emote_saved = "«%s» ahora está en la ranura %d",
		from_outfit = "Del atuendo",
		own_wheel = "Rueda propia",
		emote_hint = "TECLA «.» · SOLO R15 · TODOS LO VEN",
		wheel_reset = "La rueda vuelve a usar los emotes del atuendo",
		empty = "vacío",
		wheel_title = "Emotes",
		wheel_empty = "Vacío",
		sort_popular = "Populares",
		sort_favorited = "Favoritos",
		sort_new = "Nuevos",
		search_nothing = "No se encontró nada",
		search_failed = "El catálogo no respondió",
		slot_target = "RANURA %d",
		emote_added = "«%s» añadido a la rueda",
		emote_removed = "«%s» quitado de la rueda",
		emote_exists = "«%s» ya está en la rueda",
		menu_add_wheel = "Añadir a la rueda",
		menu_front = "Mover al inicio",
		menu_remove = "Quitar",
		menu_wear_save = "Poner y guardar",
		tag_outfit = "ATUENDO",
		add = "Añadir",
		find = "Buscar",
		open_wheel = "Abrir rueda",
		wheel_count = "RUEDA DE EMOTES · %d",
		wheel_keys = "«.» — RUEDA · Q / E — PÁGINAS · R15",
		side_emotes = "CATÁLOGO DE EMOTES",
		side_avatars = "AVATARES",
		mode_players = "Jugadores",
		mode_saved = "Guardados",
		settings = "Ajustes",
		settings_title = "AJUSTES",
		intro_anim = "Animación de inicio",
		discord_notif = "Aviso de Discord",
		discord_text = "Únete al Discord de TZAR Hub: novedades, scripts nuevos y soporte.",
		copy_link = "Copiar enlace",
		dont_show = "No mostrar",
		link_copied = "Enlace de Discord copiado",
		settings_hint = "La intro y el aviso de Discord se pueden desactivar en ajustes (engranaje arriba).",
		mode_catalog = "Catálogo",
		avatar_search = "Usuario o nombre",
		type_nick = "Empieza a escribir un usuario",
		wheel_search = "Buscar emotes…",
		wheel_search_title = "Buscar",
		wheel_hint_search = "IZQ — JUGAR · DER — AÑADIR",
		language = "Idioma",
	},
	pt = {
		err_generic = "Erro: %s",
		note_bundle = "corpo do pacote %s",
		note_noappearance = "LoadCharacterAppearance está desligado neste jogo",
		note_stdanims = "animações padrão",
		note_acc_scaled = "%s reduzido x%.2f",
		note_acc_removed = "%s removido (tamanho)",
		rig_mismatch = "O rig não corresponde e não há descrição do avatar",
		applied = "Aplicado: %s [%s]",
		rules_notes = "Regras do jogo: %s",
		enter_name = "Digite um usuário ou UserId",
		player_not_found = "Jogador não encontrado: %s",
		loading_avatar = "Carregando o avatar de %s...",
		avatar_failed = "Não foi possível carregar o avatar: %s",
		no_character_of = "%s não tem personagem",
		as_on_server = "como no servidor",
		reset_done = "Voltou ao seu visual",
		export_done = "Script do visual %s copiado e salvo em workspace/%s. Coloque-o no autoexec.",
		export_saved_only = "Script do visual %s salvo em workspace/%s. Coloque-o no autoexec.",
		script_hint = "Coloque este arquivo na pasta autoexec do seu executor.",
		script_missing = "não foi possível carregar o Avatar Changer",
		no_character = "Sem personagem",
		outfit_default = "visual",
		emote_r15 = "Emotes do Roblox só funcionam em R15",
		emote_load_failed = "Não foi possível carregar o emote %s",
		asset_missing = "Asset inexistente: %s",
		not_emote = "“%s” não é um emote",
		ready = "Pronto. RightShift esconde ou mostra a janela.",
		toast_success = "PRONTO",
		toast_error = "ERRO",
		toast_now = "AGORA",
		tab_look = "Visual",
		tab_emotes = "Emotes",
		by_nick = "POR USUÁRIO · SÓ VOCÊ VÊ",
		nick_placeholder = "Usuário ou ID",
		wear = "Vestir",
		reset_look = "Voltar ao meu",
		on_server = "NO SERVIDOR",
		outfits = "VISUAIS",
		save = "Salvar",
		after_death = "Após morrer",
		game_rules = "Regras",
		my_look = "Meu visual",
		menu_as_server = "Como no servidor",
		menu_profile = "Do perfil",
		menu_export = "Exportar para autoexec",
		rmb_menu = "Botão dir. — menu",
		players = simplePlural("JOGADOR", "JOGADORES"),
		nothing_to_save = "Nada para salvar: sem personagem",
		saved_outfit = "Visual “%s” salvo",
		deleted_outfit = "Visual “%s” excluído",
		meta_original = "ORIGINAL",
		meta_copied = "COPIADO",
		meta_saved = "SALVO",
		menu_wear = "Vestir",
		menu_rename = "Renomear",
		menu_delete = "Excluir",
		emote_wheel = "RODA DE EMOTES",
		reset = "Redefinir",
		empty_slot = "Espaço vazio",
		menu_play = "Tocar",
		menu_to_slot = "No espaço %d",
		menu_clear = "Limpar",
		emote_search = "Buscar emotes no catálogo",
		emote_saved = "“%s” agora está no espaço %d",
		from_outfit = "Do visual",
		own_wheel = "Roda própria",
		emote_hint = "TECLA “.” · SÓ R15 · TODOS VEEM",
		wheel_reset = "A roda volta a usar os emotes do visual",
		empty = "vazio",
		wheel_title = "Emotes",
		wheel_empty = "Vazio",
		sort_popular = "Populares",
		sort_favorited = "Favoritos",
		sort_new = "Novos",
		search_nothing = "Nada encontrado",
		search_failed = "O catálogo não respondeu",
		slot_target = "ESPAÇO %d",
		emote_added = "“%s” adicionado à roda",
		emote_removed = "“%s” removido da roda",
		emote_exists = "“%s” já está na roda",
		menu_add_wheel = "Adicionar à roda",
		menu_front = "Mover para o início",
		menu_remove = "Remover",
		menu_wear_save = "Vestir e salvar",
		tag_outfit = "VISUAL",
		add = "Adicionar",
		find = "Buscar",
		open_wheel = "Abrir roda",
		wheel_count = "RODA DE EMOTES · %d",
		wheel_keys = "“.” — RODA · Q / E — PÁGINAS · R15",
		side_emotes = "CATÁLOGO DE EMOTES",
		side_avatars = "AVATARES",
		mode_players = "Jogadores",
		mode_saved = "Salvos",
		settings = "Configurações",
		settings_title = "CONFIGURAÇÕES",
		intro_anim = "Animação de abertura",
		discord_notif = "Aviso do Discord",
		discord_text = "Entre no Discord do TZAR Hub: novidades, scripts novos e suporte.",
		copy_link = "Copiar link",
		dont_show = "Não mostrar",
		link_copied = "Link do Discord copiado",
		settings_hint = "A abertura e o aviso do Discord podem ser desligados nas configurações (engrenagem no topo).",
		mode_catalog = "Catálogo",
		avatar_search = "Usuário ou nome",
		type_nick = "Comece a digitar um usuário",
		wheel_search = "Buscar emotes…",
		wheel_search_title = "Busca",
		wheel_hint_search = "ESQ — TOCAR · DIR — ADICIONAR",
		language = "Idioma",
	},
	de = {
		err_generic = "Fehler: %s",
		note_bundle = "Körper aus Bundle %s",
		note_noappearance = "LoadCharacterAppearance ist in diesem Spiel aus",
		note_stdanims = "Standardanimationen",
		note_acc_scaled = "%s verkleinert x%.2f",
		note_acc_removed = "%s entfernt (Größe)",
		rig_mismatch = "Rig passt nicht und es gibt keine Avatarbeschreibung",
		applied = "Angewendet: %s [%s]",
		rules_notes = "Spielregeln: %s",
		enter_name = "Gib einen Namen oder eine UserId ein",
		player_not_found = "Spieler nicht gefunden: %s",
		loading_avatar = "Lade Avatar von %s...",
		avatar_failed = "Avatar konnte nicht geladen werden: %s",
		no_character_of = "%s hat keinen Charakter",
		as_on_server = "wie auf dem Server",
		reset_done = "Zurück zu deinem Look",
		export_done = "Outfit-Skript für %s kopiert und in workspace/%s gespeichert. Leg es in autoexec.",
		export_saved_only = "Outfit-Skript für %s in workspace/%s gespeichert. Leg es in autoexec.",
		script_hint = "Leg diese Datei in den autoexec-Ordner deines Executors.",
		script_missing = "Avatar Changer konnte nicht geladen werden",
		no_character = "Kein Charakter",
		outfit_default = "Outfit",
		emote_r15 = "Roblox-Emotes funktionieren nur mit R15",
		emote_load_failed = "Emote %s konnte nicht geladen werden",
		asset_missing = "Asset existiert nicht: %s",
		not_emote = "„%s“ ist kein Emote",
		ready = "Bereit. RightShift blendet das Fenster ein oder aus.",
		toast_success = "FERTIG",
		toast_error = "FEHLER",
		toast_now = "JETZT",
		tab_look = "Outfit",
		tab_emotes = "Emotes",
		by_nick = "PER NAME · NUR DU SIEHST ES",
		nick_placeholder = "Name oder User-ID",
		wear = "Anziehen",
		reset_look = "Mein Look",
		on_server = "AUF DEM SERVER",
		outfits = "OUTFITS",
		save = "Speichern",
		after_death = "Nach dem Tod",
		game_rules = "Spielregeln",
		my_look = "Mein Look",
		menu_as_server = "Wie auf dem Server",
		menu_profile = "Vom Profil",
		menu_export = "Nach autoexec exportieren",
		rmb_menu = "Rechtsklick — Menü",
		players = simplePlural("SPIELER", "SPIELER"),
		nothing_to_save = "Nichts zu speichern: kein Charakter",
		saved_outfit = "Outfit „%s“ gespeichert",
		deleted_outfit = "Outfit „%s“ gelöscht",
		meta_original = "ORIGINAL",
		meta_copied = "KOPIERT",
		meta_saved = "GESPEICHERT",
		menu_wear = "Anziehen",
		menu_rename = "Umbenennen",
		menu_delete = "Löschen",
		emote_wheel = "EMOTE-RAD",
		reset = "Zurücksetzen",
		empty_slot = "Leerer Platz",
		menu_play = "Abspielen",
		menu_to_slot = "In Platz %d",
		menu_clear = "Leeren",
		emote_search = "Emotes im Katalog suchen",
		emote_saved = "„%s“ ist jetzt auf Platz %d",
		from_outfit = "Vom Outfit",
		own_wheel = "Eigenes Rad",
		emote_hint = "TASTE „.“ · NUR R15 · ALLE SEHEN ES",
		wheel_reset = "Das Rad nutzt wieder die Emotes des Outfits",
		empty = "leer",
		wheel_title = "Emotes",
		wheel_empty = "Leer",
		sort_popular = "Beliebt",
		sort_favorited = "Favoriten",
		sort_new = "Neu",
		search_nothing = "Nichts gefunden",
		search_failed = "Der Katalog antwortet nicht",
		slot_target = "PLATZ %d",
		emote_added = "„%s“ zum Rad hinzugefügt",
		emote_removed = "„%s“ aus dem Rad entfernt",
		emote_exists = "„%s“ ist schon im Rad",
		menu_add_wheel = "Zum Rad hinzufügen",
		menu_front = "Nach vorne",
		menu_remove = "Entfernen",
		menu_wear_save = "Anziehen und speichern",
		tag_outfit = "OUTFIT",
		add = "Hinzufügen",
		find = "Suchen",
		open_wheel = "Rad öffnen",
		wheel_count = "EMOTE-RAD · %d",
		wheel_keys = "„.“ — RAD · Q / E — SEITEN · R15",
		side_emotes = "EMOTE-KATALOG",
		side_avatars = "AVATARE",
		mode_players = "Spieler",
		mode_saved = "Gespeichert",
		settings = "Einstellungen",
		settings_title = "EINSTELLUNGEN",
		intro_anim = "Intro-Animation",
		discord_notif = "Discord-Hinweis",
		discord_text = "Komm in den TZAR-Hub-Discord: Updates, neue Skripte und Support.",
		copy_link = "Link kopieren",
		dont_show = "Nicht anzeigen",
		link_copied = "Discord-Link kopiert",
		settings_hint = "Intro und Discord-Hinweis lassen sich in den Einstellungen abschalten (Zahnrad oben).",
		mode_catalog = "Katalog",
		avatar_search = "Spielername oder Bundle",
		type_nick = "Tippe einen Namen ein",
		wheel_search = "Emotes suchen…",
		wheel_search_title = "Suche",
		wheel_hint_search = "LINKS — SPIELEN · RECHTS — DAZU",
		language = "Sprache",
	},
}

do
	local saved
	pcall(function()
		saved = game:GetService("HttpService"):JSONDecode(readfile("AvatarChanger/config.json")).lang
	end)
	local locale = ""
	pcall(function()
		locale = game:GetService("LocalizationService").RobloxLocaleId
	end)
	AC.lang = STR[saved] and saved or STR[locale:sub(1, 2)] and locale:sub(1, 2) or "en"
end

local function L(key, ...)
	local s = STR[AC.lang] and STR[AC.lang][key] or STR.en[key] or key
	if type(s) == "function" then
		return s(...)
	end
	if select("#", ...) > 0 then
		return string.format(s, ...)
	end
	return s
end

local setStatus
local function log(msg, kind)
	print("[AvatarChanger] " .. msg)
	if setStatus then
		setStatus(msg, kind)
	end
end

local function connect(sig, fn)
	local c = sig:Connect(fn)
	table.insert(AC.conns, c)
	return c
end

local function prop(inst, name)
	local ok, v = pcall(function()
		return inst[name]
	end)
	if ok then
		return v
	end
end

-- AvatarSettings asset ids: 0, or -1 on newer clients, mean "no override".
local function assetProp(inst, name)
	local v = prop(inst, name)
	return if type(v) == "number" and v > 0 then v else 0
end

local function own(inst)
	inst:SetAttribute("AC_Owned", true)
	return inst
end

local function isOwned(inst)
	return inst:GetAttribute("AC_Owned") == true
end

local function run(fn, ...)
	if AC.busy then
		return
	end
	AC.busy = true
	local ok, err = pcall(fn, ...)
	AC.busy = false
	if not ok then
		log(L("err_generic", tostring(err)), true)
	end
end


local function httpJson(url)
	if not request then
		return nil
	end
	local ok, res = pcall(request, { Url = url, Method = "GET" })
	if not ok or not res or res.StatusCode ~= 200 then
		return nil
	end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, res.Body)
	return ok2 and data or nil
end

local rulesCache
local function getRules()
	if rulesCache then
		return rulesCache
	end
	local r = {}
	r.legacy = httpJson("https://avatar.roblox.com/v1/game-start-info?universeId=" .. game.GameId)
	local ok, as = pcall(game.GetService, game, "AvatarSettings")
	local root = ok and as and as:FindFirstChildOfClass("AvatarRules")
	if root then
		r.body = root:FindFirstChildOfClass("AvatarBodyRules")
		r.acc = root:FindFirstChildOfClass("AvatarAccessoryRules")
		r.cloth = root:FindFirstChildOfClass("AvatarClothingRules")
		r.anim = root:FindFirstChildOfClass("AvatarAnimationRules")
	end
	r.loadAppearance = StarterPlayer.LoadCharacterAppearance
	rulesCache = r
	return r
end

local ASSET_FIELD = {
	[2] = "GraphicTShirt",
	[11] = "Shirt",
	[12] = "Pants",
	[17] = "Head",
	[18] = "Face",
	[27] = "Torso",
	[28] = "RightArm",
	[29] = "LeftArm",
	[30] = "LeftLeg",
	[31] = "RightLeg",
	[78] = "MoodAnimation",
	[79] = "Head",
}
local ANIM_FIELDS = {
	"ClimbAnimation",
	"FallAnimation",
	"IdleAnimation",
	"JumpAnimation",
	"MoodAnimation",
	"RunAnimation",
	"SwimAnimation",
	"WalkAnimation",
}
local BODY_FIELDS = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }

local function setAccessoryOfType(desc, accType, assetId, layered)
	pcall(function()
		local out = {}
		for _, a in ipairs(desc:GetAccessories(true)) do
			if a.AccessoryType ~= accType then
				table.insert(out, a)
			end
		end
		table.insert(out, {
			AssetId = assetId,
			AccessoryType = accType,
			IsLayered = layered,
			Order = layered and #out + 1 or nil,
		})
		desc:SetAccessories(out, true)
	end)
end

local function clampField(desc, field, lo, hi, notes)
	if not lo or not hi or (lo == 0 and hi == 0) then
		return
	end
	local v = desc[field]
	local c = math.clamp(v, math.min(lo, hi), math.max(lo, hi))
	if math.abs(c - v) > 1e-4 then
		desc[field] = c
		table.insert(notes, string.format("%s %.2f→%.2f", field, v, c))
	end
end

local function clampRange(desc, field, range, notes)
	if typeof(range) == "NumberRange" then
		clampField(desc, field, range.Min, range.Max, notes)
	end
end

local function applyBundle(desc, bundleId, keepHead, notes)
	local data = httpJson("https://catalog.roblox.com/v1/bundles/" .. bundleId .. "/details")
	if not data or not data.items then
		return
	end
	for _, it in ipairs(data.items) do
		if it.type == "Asset" then
			local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, it.id)
			local field = ok and info and ASSET_FIELD[info.AssetTypeId]
			if field and not (keepHead and field == "Head") then
				desc[field] = it.id
			end
		end
	end
	table.insert(notes, L("note_bundle", tostring(bundleId)))
end

local function applyRules(desc, notes)
	local r = getRules()
	local post = { clips = {} }

	if r.loadAppearance == false then
		table.insert(notes, L("note_noappearance"))
	end

	local legacy = r.legacy
	if legacy then
		local mn, mx = legacy.universeAvatarMinScales or {}, legacy.universeAvatarMaxScales or {}
		local map = {
			height = "HeightScale",
			width = "WidthScale",
			head = "HeadScale",
			depth = "DepthScale",
			proportion = "ProportionScale",
			bodyType = "BodyTypeScale",
		}
		for key, field in pairs(map) do
			clampField(desc, field, mn[key], mx[key], notes)
		end
		for _, o in ipairs(legacy.universeAvatarAssetOverrides or {}) do
			local field = ASSET_FIELD[o.assetTypeID]
			if field and not o.isPlayerChoice and (tonumber(o.assetID) or 0) > 0 then
				desc[field] = o.assetID
				table.insert(notes, field .. "=" .. o.assetID)
			end
		end
		if tostring(legacy.allowCustomAnimations) == "False" then
			for _, f in ipairs(ANIM_FIELDS) do
				desc[f] = 0
			end
			table.insert(notes, L("note_stdanims"))
		end
	end

	local b = r.body
	if b then
		local mode = prop(b, "AppearanceMode")
		if mode == Enum.AvatarSettingsAppearanceMode.CustomParts then
			for _, part in ipairs({ "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Face" }) do
				local id = assetProp(b, "Custom" .. part .. "Id")
				if prop(b, "Custom" .. part .. "Enabled") and id ~= 0 then
					desc[part] = id
					table.insert(notes, part .. "=" .. id)
				end
			end
			if prop(b, "CustomMoodEnabled") and assetProp(b, "CustomMoodId") ~= 0 then
				desc.MoodAnimation = assetProp(b, "CustomMoodId")
			end
			if prop(b, "CustomEyebrowEnabled") and assetProp(b, "CustomEyebrowId") ~= 0 then
				setAccessoryOfType(desc, Enum.AccessoryType.Eyebrow, assetProp(b, "CustomEyebrowId"), false)
			end
			if prop(b, "CustomEyelashEnabled") and assetProp(b, "CustomEyelashId") ~= 0 then
				setAccessoryOfType(desc, Enum.AccessoryType.Eyelash, assetProp(b, "CustomEyelashId"), false)
			end
		elseif mode == Enum.AvatarSettingsAppearanceMode.CustomBody then
			local bundle = assetProp(b, "CustomBodyBundleId")
			if prop(b, "CustomBodyType") == Enum.AvatarSettingsCustomBodyType.BundleId and bundle ~= 0 then
				applyBundle(desc, bundle, prop(b, "KeepPlayerHead"), notes)
			end
		end
		for _, part in ipairs(BODY_FIELDS) do
			local v = assetProp(b, part .. "Override")
			if v ~= 0 then
				desc[part] = v
				table.insert(notes, part .. "=" .. v)
			end
		end
		if prop(b, "ScaleMode") == Enum.AvatarSettingsScaleMode.CustomScale then
			clampRange(desc, "HeightScale", prop(b, "CustomHeightScale"), notes)
			clampRange(desc, "WidthScale", prop(b, "CustomWidthScale"), notes)
			clampRange(desc, "HeadScale", prop(b, "CustomHeadScale"), notes)
			clampRange(desc, "BodyTypeScale", prop(b, "CustomBodyTypeScale"), notes)
			clampRange(desc, "ProportionScale", prop(b, "CustomProportionsScale"), notes)
		end
		if prop(b, "BuildMode") == Enum.AvatarSettingsBuildMode.CustomBuild then
			clampRange(desc, "HeightScale", prop(b, "CustomBuildHeight"), notes)
			clampRange(desc, "WidthScale", prop(b, "CustomBuildWidth"), notes)
			clampRange(desc, "HeadScale", prop(b, "CustomBuildHead"), notes)
			clampRange(desc, "BodyTypeScale", prop(b, "CustomBuildBodyType"), notes)
			clampRange(desc, "ProportionScale", prop(b, "CustomBuildProportions"), notes)
		end
	end

	local a = r.acc
	if a then
		local custom = prop(a, "CustomAccessoryMode") == Enum.AvatarSettingsCustomAccessoryMode.CustomAccessories
		local slots = {
			Back = "Back",
			Face = "Face",
			Front = "Front",
			Hair = "Hair",
			Head = "Hat",
			Neck = "Neck",
			Shoulder = "Shoulder",
			Waist = "Waist",
		}
		for slot, accType in pairs(slots) do
			local id = 0
			if custom and prop(a, "Custom" .. slot .. "AccessoryEnabled") then
				id = assetProp(a, "Custom" .. slot .. "AccessoryId")
			end
			if id == 0 then
				id = assetProp(a, slot .. "AccessoryOverride")
			end
			if id ~= 0 then
				setAccessoryOfType(desc, Enum.AccessoryType[accType], id, false)
				table.insert(notes, accType .. "=" .. id)
			end
		end
		local method = prop(a, "LimitMethod")
		if
			prop(a, "AccessoryMode") == Enum.AvatarSettingsAccessoryMode.CustomLimit
			and (
				method == Enum.AvatarSettingsAccessoryLimitMethod.Scale
				or method == Enum.AvatarSettingsAccessoryLimitMethod.Remove
			)
		then
			post.accLimit = prop(a, "LimitBounds")
			post.limitMethod = method
		end
	end

	local c = r.cloth
	if c then
		local custom = prop(c, "CustomClothingMode") == Enum.AvatarSettingsCustomClothingMode.CustomClothing
		local function pick(key)
			local id = 0
			if custom and prop(c, "Custom" .. key .. "AccessoryEnabled") then
				id = assetProp(c, "Custom" .. key .. "AccessoryId")
			end
			if id == 0 then
				id = assetProp(c, key .. "AccessoryOverride")
			end
			return id
		end
		for key, field in pairs({ ClassicShirts = "Shirt", ClassicPants = "Pants", ClassicTShirts = "GraphicTShirt" }) do
			local id = pick(key)
			if id ~= 0 then
				desc[field] = id
				table.insert(notes, field .. "=" .. id)
			end
		end
		local layered = {
			Jacket = "Jacket",
			Shirt = "Shirt",
			Sweater = "Sweater",
			TShirt = "TShirt",
			Pants = "Pants",
			Shorts = "Shorts",
			DressSkirt = "DressSkirt",
			LeftShoes = "LeftShoe",
			RightShoes = "RightShoe",
		}
		for key, accType in pairs(layered) do
			local id = pick(key)
			if id ~= 0 then
				setAccessoryOfType(desc, Enum.AccessoryType[accType], id, true)
				table.insert(notes, accType .. "=" .. id)
			end
		end
		if prop(c, "ClothingMode") == Enum.AvatarSettingsClothingMode.CustomLimit then
			post.clothLimit = prop(c, "LimitBounds")
		end
	end

	local an = r.anim
	if an then
		local packs = prop(an, "AnimationPacksMode")
		if packs and packs ~= Enum.AvatarSettingsAnimationPacksMode.PlayerChoice then
			for _, f in ipairs(ANIM_FIELDS) do
				desc[f] = 0
			end
			table.insert(notes, L("note_stdanims"))
		end
		local customClips = prop(an, "AnimationClipsMode") == Enum.AvatarSettingsAnimationClipsMode.CustomClips
		local clipSlots = {
			Climb = "climb",
			Fall = "fall",
			Idle = "idle",
			Jump = "jump",
			Run = "run",
			Swim = "swim",
			SwimIdle = "swimidle",
			Walk = "walk",
		}
		for key, slot in pairs(clipSlots) do
			local id = 0
			if customClips and prop(an, "Custom" .. key .. "AnimationEnabled") then
				id = assetProp(an, "Custom" .. key .. "AnimationId")
			end
			if id == 0 then
				id = assetProp(an, key .. "AnimationOverride")
			end
			if id ~= 0 then
				post.clips[slot] = id
			end
		end
		local mood = assetProp(an, "MoodAnimationOverride")
		if mood ~= 0 then
			desc.MoodAnimation = mood
		end
	end

	return post
end

local function scaleAccessory(h, f)
	h.Size = h.Size * f
	local m = h:FindFirstChildOfClass("SpecialMesh")
	if m then
		m.Scale = m.Scale * f
	end
	for _, a in ipairs(h:GetChildren()) do
		if a:IsA("Attachment") then
			a.Position = a.Position * f
		end
	end
end

local function limitAccessories(model, post, notes)
	for _, acc in ipairs(model:GetChildren()) do
		local h = acc:IsA("Accoutrement") and acc:FindFirstChild("Handle")
		if h and h:IsA("BasePart") then
			local layered = h:FindFirstChildOfClass("WrapLayer") ~= nil
			local bounds = if layered then post.clothLimit else post.accLimit
			if bounds and bounds.Magnitude > 0 then
				local f = 1
				for _, ax in ipairs({ "X", "Y", "Z" }) do
					local lim = bounds[ax]
					if lim > 0 and h.Size[ax] > lim then
						f = math.min(f, lim / h.Size[ax])
					end
				end
				if f < 1 then
					if not layered and post.limitMethod == Enum.AvatarSettingsAccessoryLimitMethod.Scale then
						scaleAccessory(h, f)
						table.insert(notes, L("note_acc_scaled", acc.Name, f))
					else
						table.insert(notes, L("note_acc_removed", acc.Name))
						acc:Destroy()
					end
				end
			end
		end
	end
end


local R15_PARTS = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
}
local R6_PARTS = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
local PART_VISUALS = { SpecialMesh = true, FaceControls = true, WrapTarget = true, SurfaceAppearance = true }

local function isPartVisual(x)
	return PART_VISUALS[x.ClassName] or (x:IsA("Decal") and x.Name == "face")
end

local function isAvatarAccessory(x)
	if not x:IsA("Accoutrement") then
		return false
	end
	local h = x:FindFirstChild("Handle")
	return h ~= nil and h:IsA("BasePart")
end

local function isAppearanceItem(x)
	return x:IsA("Clothing") or x:IsA("ShirtGraphic") or x:IsA("BodyColors") or x:IsA("CharacterMesh")
end

local function getAvatarAccessories(model)
	local out = {}
	for _, d in ipairs(model:GetDescendants()) do
		if isAvatarAccessory(d) and not d:FindFirstAncestorWhichIsA("Tool") and not d:FindFirstAncestorWhichIsA("Accoutrement") then
			table.insert(out, d)
		end
	end
	return out
end

local function partNames(hum)
	return if hum.RigType == Enum.HumanoidRigType.R15 then R15_PARTS else R6_PARTS
end

local function snapshot(char)
	for _, d in ipairs(char:GetDescendants()) do
		if not d.Archivable then
			pcall(function()
				d.Archivable = true
			end)
		end
	end
	local prev = char.Archivable
	char.Archivable = true
	local c = char:Clone()
	char.Archivable = prev
	for _, d in ipairs(c:GetDescendants()) do
		if d.ClassName == "Script" or d:IsA("Tool") then
			d:Destroy()
		end
	end
	return c
end

local function syncPart(src, dst)
	if dst:IsA("MeshPart") and src:IsA("MeshPart") then
		if dst.MeshId ~= src.MeshId then
			pcall(function()
				dst.MeshId = src.MeshId
			end)
		end
		if dst.TextureID ~= src.TextureID then
			pcall(function()
				dst.TextureID = src.TextureID
			end)
		end
		if gethiddenproperty and sethiddenproperty then
			local ok, initial = pcall(gethiddenproperty, src, "InitialSize")
			if ok and initial then
				pcall(sethiddenproperty, dst, "InitialSize", initial)
			end
		end
	end
	dst.Size = src.Size
	dst.Color = src.Color
	for _, c in ipairs(dst:GetChildren()) do
		if isPartVisual(c) then
			c:Destroy()
		end
	end
	for _, c in ipairs(src:GetChildren()) do
		if isPartVisual(c) then
			own(c:Clone()).Parent = dst
		elseif c:IsA("Attachment") then
			local a = dst:FindFirstChild(c.Name)
			if a and a:IsA("Attachment") then
				a.CFrame = c.CFrame
			else
				own(c:Clone()).Parent = dst
			end
		elseif c:IsA("ValueBase") and (c.Name == "OriginalSize" or c.Name == "AvatarPartScaleType") then
			local v = dst:FindFirstChild(c.Name)
			if v and v.ClassName == c.ClassName then
				v.Value = c.Value
			end
		end
	end
end

local function findSourceMotor(src, m)
	for _, d in ipairs(src:GetDescendants()) do
		if d:IsA("Motor6D") and d.Name == m.Name and d.Part1 and d.Part1.Name == m.Part1.Name then
			return d
		end
	end
end

local function syncJoints(src, char)
	for _, m in ipairs(char:GetDescendants()) do
		if m:IsA("Motor6D") and m.Part0 and m.Part1 and m.Part0.Parent == char and m.Part1.Parent == char then
			local done = false
			for _, a1 in ipairs(m.Part1:GetChildren()) do
				if a1:IsA("Attachment") and a1.Name:match("RigAttachment$") then
					local a0 = m.Part0:FindFirstChild(a1.Name)
					if a0 and a0:IsA("Attachment") then
						m.C0 = a0.CFrame
						m.C1 = a1.CFrame
						done = true
						break
					end
				end
			end
			if not done then
				local sm = findSourceMotor(src, m)
				if sm then
					m.C0 = sm.C0
					m.C1 = sm.C1
				end
			end
		end
	end
end

local function findBodyAttachment(char, name)
	for _, p in ipairs(char:GetChildren()) do
		if p:IsA("BasePart") then
			local a = p:FindFirstChild(name)
			if a and a:IsA("Attachment") then
				return a
			end
		end
	end
end

local function attachAccessory(acc, char)
	local h = acc:FindFirstChild("Handle")
	if not h or not h:IsA("BasePart") then
		return
	end
	for _, j in ipairs(h:GetChildren()) do
		if j:IsA("JointInstance") or j:IsA("WeldConstraint") then
			j:Destroy()
		end
	end
	h.Anchored = false
	h.CanCollide = false
	h.Massless = true
	pcall(function()
		h.CanTouch = false
		h.CanQuery = false
	end)
	local w = Instance.new("Weld")
	w.Name = "AccessoryWeld"
	w.Part0 = h
	for _, att in ipairs(h:GetChildren()) do
		if att:IsA("Attachment") then
			local target = findBodyAttachment(char, att.Name)
			if target then
				w.C0 = att.CFrame
				w.C1 = target.CFrame
				w.Part1 = target.Parent
				break
			end
		end
	end
	if not w.Part1 then
		local head = char:FindFirstChild("Head")
		if not head then
			return
		end
		w.C0 = acc.AttachmentPoint
		w.C1 = CFrame.new(0, head.Size.Y / 2, 0)
		w.Part1 = head
	end
	w.Parent = h
end

local function animIds(sv)
	local t = {}
	for _, a in ipairs(sv:GetChildren()) do
		if a:IsA("Animation") then
			table.insert(t, a.AnimationId)
		end
	end
	return table.concat(t, ";")
end

local function copyAnimate(src, char, clips)
	local sA, dA = src:FindFirstChild("Animate"), char:FindFirstChild("Animate")
	if not (sA and dA) then
		return
	end
	local changed = false
	for _, sv in ipairs(sA:GetChildren()) do
		local dv = dA:FindFirstChild(sv.Name)
		if sv:IsA("StringValue") and dv and dv:IsA("StringValue") and animIds(sv) ~= animIds(dv) then
			for _, c in ipairs(dv:GetChildren()) do
				c:Destroy()
			end
			for _, c in ipairs(sv:GetChildren()) do
				c:Clone().Parent = dv
			end
			changed = true
		end
	end
	for slot, id in pairs(clips or {}) do
		local dv = dA:FindFirstChild(slot)
		local a = dv and dv:FindFirstChildOfClass("Animation")
		local want = "rbxassetid://" .. id
		if a and a.AnimationId ~= want then
			a.AnimationId = want
			changed = true
		end
	end
	if changed then
		local hum = char:FindFirstChildOfClass("Humanoid")
		local animator = hum and hum:FindFirstChildOfClass("Animator")
		if animator then
			for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
				t:Stop(0)
			end
		end
		dA.Disabled = true
		task.wait()
		dA.Disabled = false
	end
end

local function transplant(src, char, clips)
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	local isR15 = hum.RigType == Enum.HumanoidRigType.R15
	AC.expect = {}
	for _, n in ipairs(partNames(hum)) do
		local s, d = src:FindFirstChild(n), char:FindFirstChild(n)
		if s and d and s:IsA("BasePart") and d:IsA("BasePart") then
			syncPart(s, d)
			local okI, initial = pcall(gethiddenproperty, d, "InitialSize")
			AC.expect[d] = {
				MeshId = d:IsA("MeshPart") and d.MeshId or nil,
				Size = d.Size,
				InitialSize = d:IsA("MeshPart") and okI and initial or nil,
			}
		end
	end

	local sRoot, dRoot = src:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("HumanoidRootPart")
	if sRoot and dRoot then
		for _, a in ipairs(sRoot:GetChildren()) do
			local d = a:IsA("Attachment") and dRoot:FindFirstChild(a.Name)
			if d and d:IsA("Attachment") then
				d.CFrame = a.CFrame
			end
		end
	end
	syncJoints(src, char)

	local srcHum = src:FindFirstChildOfClass("Humanoid")
	if isR15 and srcHum and sRoot and dRoot then
		hum.HipHeight = srcHum.HipHeight + (sRoot.Size.Y - dRoot.Size.Y) / 2
	end

	for _, c in ipairs(char:GetChildren()) do
		if isAppearanceItem(c) then
			c:Destroy()
		end
	end
	for _, acc in ipairs(getAvatarAccessories(char)) do
		acc:Destroy()
	end
	for _, c in ipairs(src:GetChildren()) do
		if isAppearanceItem(c) then
			own(c:Clone()).Parent = char
		end
	end
	for _, c in ipairs(getAvatarAccessories(src)) do
		local acc = own(c:Clone())
		attachAccessory(acc, char)
		acc.Parent = char
	end

	if isR15 then
		copyAnimate(src, char, clips)
	end
	AC.appliedChar = char
end


local function buildModel(desc, rig, useRules, notes)
	desc = desc:Clone()
	local post = { clips = {} }
	if useRules then
		post = applyRules(desc, notes)
	end
	local model = Players:CreateHumanoidModelFromDescription(desc, rig)
	if useRules then
		limitAccessories(model, post, notes)
	end
	pcall(ContentProvider.PreloadAsync, ContentProvider, { model })
	return model, post.clips
end

local function applyToCurrent()
	local char = lp.Character
	local src = AC.source
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not (src and hum) then
		return
	end
	if not AC.originals[char] then
		AC.originals[char] = snapshot(char)
	end
	if not src.model or src.rig ~= hum.RigType then
		if not src.desc then
			log(L("rig_mismatch"), true)
			return
		end
		if src.model then
			src.model:Destroy()
		end
		src.notes = {}
		src.model, src.clips = buildModel(src.desc, hum.RigType, AC.useRules, src.notes)
		src.rig = hum.RigType
		src.fromDesc = true
	end
	transplant(src.model, char, src.clips)
	local msg = L("applied", src.label, hum.RigType.Name)
	if src.notes and #src.notes > 0 then
		msg ..= "\n" .. L("rules_notes", table.concat(src.notes, ", "))
	end
	log(msg, "success")
	if AC.onChanged then
		task.spawn(AC.onChanged)
	end
end

local function setSource(src)
	if AC.source and AC.source.model then
		AC.source.model:Destroy()
	end
	AC.source = src
	applyToCurrent()
end

local function resolveUser(text)
	text = text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^@", "")
	if text == "" then
		return nil, L("enter_name")
	end
	if tonumber(text) then
		return tonumber(text), text
	end
	local lower = text:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower() == lower or p.DisplayName:lower() == lower then
			return p.UserId, p.Name
		end
	end
	local ok, id = pcall(Players.GetUserIdFromNameAsync, Players, text)
	if ok and id then
		return id, text
	end
	return nil, L("player_not_found", text)
end

function AC.ApplyUser(text)
	run(function()
		local id, label = resolveUser(text)
		if not id then
			log(label, true)
			return
		end
		log(L("loading_avatar", label))
		local ok, desc = pcall(Players.GetHumanoidDescriptionFromUserId, Players, id)
		if not ok then
			log(L("avatar_failed", tostring(desc)), true)
			return
		end
		setSource({ desc = desc, label = label })
	end)
end

function AC.CopyPlayer(plr)
	run(function()
		local theirChar = plr.Character
		local theirHum = theirChar and theirChar:FindFirstChildOfClass("Humanoid")
		if not theirHum then
			log(L("no_character_of", plr.Name), true)
			return
		end
		local okD, desc = pcall(theirHum.GetAppliedDescription, theirHum)
		if not okD then
			desc = theirHum:FindFirstChildOfClass("HumanoidDescription")
		end
		local src = { desc = desc, label = plr.Name .. " (" .. L("as_on_server") .. ")" }
		local myHum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if myHum and myHum.RigType == theirHum.RigType then
			src.model = snapshot(theirChar)
			src.rig = theirHum.RigType
		end
		setSource(src)
	end)
end

function AC.Reset()
	run(function()
		local char = lp.Character
		if AC.source and AC.source.model then
			AC.source.model:Destroy()
		end
		AC.source = nil
		local orig = char and AC.originals[char]
		if orig then
			transplant(orig, char)
		end
		AC.expect = {}
		AC.appliedChar = nil
		log(L("reset_done"), "success")
		if AC.onChanged then
			task.spawn(AC.onChanged)
		end
	end)
end

function AC.SetRules(on)
	AC.useRules = on
	local src = AC.source
	if src and src.fromDesc then
		src.model:Destroy()
		src.model = nil
		run(applyToCurrent)
	end
end

local function verify()
	local char = lp.Character
	if AC.busy or not AC.source or not char or AC.appliedChar ~= char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return
	end
	for _, n in ipairs(partNames(hum)) do
		local p = char:FindFirstChild(n)
		local exp = p and AC.expect[p]
		if p and not exp then
			return run(applyToCurrent)
		end
		if exp then
			local okI, initial = pcall(gethiddenproperty, p, "InitialSize")
			local initialChanged = exp.InitialSize and okI and (initial - exp.InitialSize).Magnitude > 1e-3
			if exp.MeshId and p.MeshId ~= exp.MeshId or (p.Size - exp.Size).Magnitude > 1e-3 or initialChanged then
				return run(applyToCurrent)
			end
			for _, c in ipairs(p:GetChildren()) do
				if isPartVisual(c) and not isOwned(c) then
					return run(applyToCurrent)
				end
			end
		end
	end
	for _, c in ipairs(char:GetChildren()) do
		if isAppearanceItem(c) and not isOwned(c) then
			return run(applyToCurrent)
		end
	end
	for _, acc in ipairs(getAvatarAccessories(char)) do
		if not isOwned(acc) then
			return run(applyToCurrent)
		end
	end
end

local function waitReady(char)
	char:WaitForChild("Humanoid", 10)
	char:WaitForChild("HumanoidRootPart", 10)
	local t0 = os.clock()
	while not lp:HasAppearanceLoaded() and os.clock() - t0 < 6 and lp.Character == char do
		task.wait(0.1)
	end
	task.wait(0.3)
end

connect(lp.CharacterAdded, function(char)
	if not (AC.persist and AC.source) then
		return
	end
	waitReady(char)
	if lp.Character == char and AC.alive then
		run(applyToCurrent)
	end
end)

task.spawn(function()
	while AC.alive do
		task.wait(0.5)
		pcall(verify)
	end
end)


local DESC_NUMBERS = {
	"Head",
	"Torso",
	"LeftArm",
	"RightArm",
	"LeftLeg",
	"RightLeg",
	"Face",
	"Shirt",
	"Pants",
	"GraphicTShirt",
	"BodyTypeScale",
	"DepthScale",
	"HeadScale",
	"HeightScale",
	"ProportionScale",
	"WidthScale",
	"ClimbAnimation",
	"FallAnimation",
	"IdleAnimation",
	"JumpAnimation",
	"MoodAnimation",
	"RunAnimation",
	"SwimAnimation",
	"WalkAnimation",
}
local DESC_COLORS = { "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" }

local function numStr(n)
	if n == math.floor(n) then
		return string.format("%d", n)
	end
	return string.format("%.17g", n)
end

local function v3(v)
	return v and { v.X, v.Y, v.Z } or nil
end

local function serializeDescription(desc)
	local t = { numbers = {}, colors = {}, accessories = {} }
	for _, f in ipairs(DESC_NUMBERS) do
		t.numbers[f] = numStr(desc[f])
	end
	for _, f in ipairs(DESC_COLORS) do
		t.colors[f] = desc[f]:ToHex()
	end
	for _, a in ipairs(desc:GetAccessories(true)) do
		table.insert(t.accessories, {
			AssetId = numStr(a.AssetId),
			AccessoryType = a.AccessoryType.Name,
			IsLayered = a.IsLayered,
			Order = a.Order,
			Puffiness = a.Puffiness,
			Position = v3(a.Position),
			Rotation = v3(a.Rotation),
			Scale = v3(a.Scale),
		})
	end
	local okE, emotes = pcall(desc.GetEmotes, desc)
	local okQ, equipped = pcall(desc.GetEquippedEmotes, desc)
	if okE and okQ and #equipped > 0 then
		t.emotes, t.equippedEmotes = {}, equipped
		for name, ids in pairs(emotes) do
			t.emotes[name] = {}
			for _, id in ipairs(ids) do
				table.insert(t.emotes[name], numStr(id))
			end
		end
	end
	return t
end

local function deserializeDescription(t)
	local desc = Instance.new("HumanoidDescription")
	for f, v in pairs(t.numbers or {}) do
		pcall(function()
			desc[f] = tonumber(v) or 0
		end)
	end
	for f, hex in pairs(t.colors or {}) do
		pcall(function()
			desc[f] = Color3.fromHex(hex)
		end)
	end
	local list = {}
	for _, a in ipairs(t.accessories or {}) do
		local okT, accType = pcall(function()
			return Enum.AccessoryType[a.AccessoryType]
		end)
		local item = {
			AssetId = tonumber(a.AssetId) or 0,
			AccessoryType = okT and accType or Enum.AccessoryType.Unknown,
			IsLayered = a.IsLayered == true,
			Order = a.Order,
			Puffiness = a.Puffiness,
		}
		if a.Position then
			item.Position = Vector3.new(table.unpack(a.Position))
		end
		if a.Rotation then
			item.Rotation = Vector3.new(table.unpack(a.Rotation))
		end
		if a.Scale then
			item.Scale = Vector3.new(table.unpack(a.Scale))
		end
		table.insert(list, item)
	end
	if not pcall(desc.SetAccessories, desc, list, true) then
		for _, item in ipairs(list) do
			item.Position, item.Rotation, item.Scale = nil, nil, nil
		end
		pcall(desc.SetAccessories, desc, list, true)
	end
	if t.emotes and t.equippedEmotes then
		local emotes = {}
		for name, ids in pairs(t.emotes) do
			emotes[name] = {}
			for _, id in ipairs(ids) do
				table.insert(emotes[name], tonumber(id))
			end
		end
		pcall(desc.SetEmotes, desc, emotes)
		pcall(desc.SetEquippedEmotes, desc, t.equippedEmotes)
	end
	return desc
end

local function buildOutfitScript(desc, label)
	local data = serializeDescription(desc)
	data.label = label
	return table.concat({
		'-- Avatar Changer: "' .. label .. '" (' .. os.date("%d.%m.%Y %H:%M") .. ")",
		"-- " .. L("script_hint"),
		"local OUTFIT = [==[" .. HttpService:JSONEncode(data) .. "]==]",
		"if not game:IsLoaded() then game.Loaded:Wait() end",
		'local Players = game:GetService("Players")',
		"while not Players.LocalPlayer do task.wait() end",
		"if not getgenv().AvatarChanger then",
		'\tlocal src = isfile("avatar_changer.lua") and readfile("avatar_changer.lua")',
		'\t\tor game:HttpGet("' .. SOURCE_URL .. '")',
		'\tif not src or src == "" then warn("[AvatarChanger] ' .. L("script_missing") .. '") return end',
		"\tloadstring(src)()",
		"end",
		"getgenv().AvatarChanger.ApplyOutfit(OUTFIT)",
		"",
	}, "\n")
end

local function exportDescription(desc, label)
	local source = buildOutfitScript(desc, label)
	local fileName = "AvatarExports/" .. (label:gsub("[^%w_%-]", "_")) .. ".lua"
	pcall(makefolder, "AvatarExports")
	local saved = pcall(writefile, fileName, source)
	local copied = setclipboard ~= nil and pcall(setclipboard, source)
	if not saved and not copied then
		log(L("err_generic", "writefile/setclipboard"), true)
	else
		log(L(copied and "export_done" or "export_saved_only", label, fileName), "success")
	end
	return source
end

function AC.ExportMine()
	run(function()
		if AC.source and AC.source.desc then
			exportDescription(AC.source.desc, (AC.source.label:gsub(" %(.*%)$", "")))
			return
		end
		local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
		if not hum then
			log(L("no_character"), true)
			return
		end
		exportDescription(hum:GetAppliedDescription(), lp.Name)
	end)
end

function AC.ExportPlayer(plr)
	run(function()
		local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
		if not hum then
			log(L("no_character_of", plr.Name), true)
			return
		end
		local ok, desc = pcall(hum.GetAppliedDescription, hum)
		if not ok then
			desc = hum:FindFirstChildOfClass("HumanoidDescription")
		end
		exportDescription(desc, plr.Name)
	end)
end

function AC.ApplyOutfit(data)
	if type(data) == "string" then
		data = HttpService:JSONDecode(data)
	end
	local desc = deserializeDescription(data)
	local label = data.label or L("outfit_default")
	task.spawn(function()
		local char = lp.Character or lp.CharacterAdded:Wait()
		waitReady(char)
		run(setSource, { desc = desc, label = label .. " (autoexec)" })
	end)
end


local EMOTE_SLOTS = 8
local EMOTE_ASSET_TYPE = 61
local gunzip
do
	local LBASE = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258 }
	local LEXT = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0 }
	local DBASE = {
		1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769,
		1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577,
	}
	local DEXT = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13 }
	local ORDER = { 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 }

	local function huff(lengths, n, from)
		local count, offs, sym = {}, {}, {}
		for i = 0, 15 do
			count[i] = 0
		end
		for i = 0, n - 1 do
			local l = lengths[from + i] or 0
			count[l] += 1
		end
		count[0] = 0
		offs[1] = 0
		for i = 1, 14 do
			offs[i + 1] = offs[i] + count[i]
		end
		for i = 0, n - 1 do
			local l = lengths[from + i] or 0
			if l ~= 0 then
				sym[offs[l]] = i
				offs[l] += 1
			end
		end
		return { count = count, symbol = sym }
	end

	gunzip = function(data)
		local flg = data:byte(4)
		local pos = 11
		if bit32.band(flg, 4) ~= 0 then
			pos += 2 + data:byte(pos) + data:byte(pos + 1) * 256
		end
		if bit32.band(flg, 8) ~= 0 then
			pos = data:find("\0", pos, true) + 1
		end
		if bit32.band(flg, 16) ~= 0 then
			pos = data:find("\0", pos, true) + 1
		end
		if bit32.band(flg, 2) ~= 0 then
			pos += 2
		end
		local buf, cnt = 0, 0
		local out = {}
		local function bits(n)
			while cnt < n do
				buf += bit32.lshift(data:byte(pos) or 0, cnt)
				pos += 1
				cnt += 8
			end
			local v = bit32.band(buf, bit32.lshift(1, n) - 1)
			buf = bit32.rshift(buf, n)
			cnt -= n
			return v
		end
		local function decode(h)
			local code, first, index = 0, 0, 0
			for len = 1, 15 do
				code += bits(1)
				local c = h.count[len]
				if code - c < first then
					return h.symbol[index + (code - first)]
				end
				index += c
				first = (first + c) * 2
				code *= 2
			end
			error("bad huffman code")
		end
		repeat
			local final, typ = bits(1), bits(2)
			if typ == 0 then
				buf, cnt = 0, 0
				local len = data:byte(pos) + data:byte(pos + 1) * 256
				pos += 4
				for i = 0, len - 1 do
					out[#out + 1] = data:byte(pos + i)
				end
				pos += len
			else
				local lens, nlen, ndist = {}, 288, 30
				if typ == 1 then
					for i = 0, 143 do
						lens[i] = 8
					end
					for i = 144, 255 do
						lens[i] = 9
					end
					for i = 256, 279 do
						lens[i] = 7
					end
					for i = 280, 287 do
						lens[i] = 8
					end
					for i = 0, 29 do
						lens[288 + i] = 5
					end
				else
					nlen, ndist = bits(5) + 257, bits(5) + 1
					local ncode = bits(4) + 4
					local cl = {}
					for i = 1, ncode do
						cl[ORDER[i]] = bits(3)
					end
					local clh = huff(cl, 19, 0)
					local raw, i = {}, 0
					while i < nlen + ndist do
						local s = decode(clh)
						if s < 16 then
							raw[i] = s
							i += 1
						else
							local rep, val = 0, 0
							if s == 16 then
								val = raw[i - 1]
								rep = 3 + bits(2)
							elseif s == 17 then
								rep = 3 + bits(3)
							else
								rep = 11 + bits(7)
							end
							for _ = 1, rep do
								raw[i] = val
								i += 1
							end
						end
					end
					for k = 0, nlen - 1 do
						lens[k] = raw[k]
					end
					for k = 0, ndist - 1 do
						lens[288 + k] = raw[nlen + k]
					end
				end
				local lh, dh = huff(lens, nlen, 0), huff(lens, ndist, 288)
				while true do
					local s = decode(lh)
					if s < 256 then
						out[#out + 1] = s
					elseif s == 256 then
						break
					else
						s -= 257
						local len = LBASE[s + 1] + bits(LEXT[s + 1])
						local ds = decode(dh)
						local dist = DBASE[ds + 1] + bits(DEXT[ds + 1])
						local start = #out - dist
						for k = 1, len do
							out[#out + 1] = out[start + k]
						end
					end
				end
			end
		until final == 1
		local parts = {}
		for i = 1, #out, 4096 do
			parts[#parts + 1] = string.char(table.unpack(out, i, math.min(i + 4095, #out)))
		end
		return table.concat(parts)
	end
end

local EMOTE_ANIMS_PATH = "AvatarChanger/emote_anims.json"
local emoteAnimIds = {}
pcall(function()
	emoteAnimIds = HttpService:JSONDecode(readfile(EMOTE_ANIMS_PATH))
end)
local emoteAnimCache = {}
local emoteAnimPending = {}
local emoteHttpFailed = {}

local function resolveEmoteAnimId(id, allowBlocking)
	local key = tostring(id)
	if emoteAnimIds[key] then
		return emoteAnimIds[key]
	end
	local animId
	if not emoteHttpFailed[id] then
		local ok, r = pcall(request, { Url = "https://assetdelivery.roblox.com/v1/asset/?id=" .. id, Method = "GET" })
		if ok and r and r.StatusCode == 200 and r.Body then
			local body = r.Body
			if body:sub(1, 2) == "\31\139" then
				local okZ, raw = pcall(gunzip, body)
				body = okZ and raw or ""
			end
			animId = body:match("rbxassetid://(%d+)") or body:match("[Aa]sset/%?[Ii][Dd]=(%d+)")
		end
		emoteHttpFailed[id] = animId == nil
	end
	if not animId and allowBlocking then
		local okG, objs = pcall(function()
			return game:GetObjects("rbxassetid://" .. id)
		end)
		local a = okG and objs[1]
		animId = a and a:IsA("Animation") and a.AnimationId:match("(%d+)$")
	end
	if animId then
		emoteAnimIds[key] = animId
		pcall(writefile, EMOTE_ANIMS_PATH, HttpService:JSONEncode(emoteAnimIds))
	end
	return animId
end

local function emoteAnimation(id, allowBlocking)
	if emoteAnimCache[id] then
		return emoteAnimCache[id]
	end
	while emoteAnimPending[id] do
		task.wait()
	end
	if emoteAnimCache[id] then
		return emoteAnimCache[id]
	end
	if emoteHttpFailed[id] and not allowBlocking then
		return nil
	end
	emoteAnimPending[id] = true
	local animId = resolveEmoteAnimId(id, allowBlocking)
	local a
	if animId then
		a = Instance.new("Animation")
		a.AnimationId = "rbxassetid://" .. animId
		emoteAnimCache[id] = a
	end
	emoteAnimPending[id] = nil
	return a
end

local function emoteSlotsOf(desc)
	local slots = {}
	if not desc then
		return slots
	end
	local ok, emotes = pcall(desc.GetEmotes, desc)
	local ok2, equipped = pcall(desc.GetEquippedEmotes, desc)
	if not (ok and ok2) then
		return slots
	end
	for _, it in ipairs(equipped) do
		local ids = emotes[it.Name]
		if ids and ids[1] and it.Slot >= 1 and it.Slot <= EMOTE_SLOTS then
			slots[it.Slot] = { id = ids[1], name = it.Name }
		end
	end
	return slots
end

AC.emoteList = {}
AC.useOutfitEmotes = true

function AC.GetWheelEmotes()
	local out, seen = {}, {}
	local function add(e, fromOutfit)
		if e and e.id and not seen[e.id] then
			seen[e.id] = true
			table.insert(out, { id = e.id, name = e.name, fromOutfit = fromOutfit })
		end
	end
	if AC.useOutfitEmotes then
		local base
		if AC.source and AC.source.desc then
			base = emoteSlotsOf(AC.source.desc)
			if next(base) == nil then
				base = nil
			end
		end
		if not base then
			local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
			local ok, d = pcall(function()
				return hum:GetAppliedDescription()
			end)
			base = emoteSlotsOf(ok and d or nil)
		end
		for i = 1, EMOTE_SLOTS do
			add(base[i], true)
		end
	end
	for _, e in ipairs(AC.emoteList) do
		add(e, false)
	end
	return out
end

function AC.HasEmote(id)
	for _, e in ipairs(AC.emoteList) do
		if e.id == id then
			return true
		end
	end
	return false
end

function AC.AddEmote(id, name)
	if AC.HasEmote(id) then
		return false
	end
	table.insert(AC.emoteList, { id = id, name = name })
	return true
end

function AC.RemoveEmote(id)
	for i, e in ipairs(AC.emoteList) do
		if e.id == id then
			table.remove(AC.emoteList, i)
			return true
		end
	end
	return false
end

function AC.MoveEmoteToFront(id)
	for i, e in ipairs(AC.emoteList) do
		if e.id == id then
			table.remove(AC.emoteList, i)
			table.insert(AC.emoteList, 1, e)
			return true
		end
	end
	return false
end

function AC.PlayEmote(id)
	local char = lp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return false
	end
	if hum.RigType ~= Enum.HumanoidRigType.R15 then
		log(L("emote_r15"), true)
		return false
	end
	local anim = emoteAnimation(id, true)
	if not anim then
		log(L("emote_load_failed", tostring(id)), true)
		return false
	end
	local animate = char:FindFirstChild("Animate")
	local pe = animate and animate:FindFirstChild("PlayEmote")
	if pe and pe:IsA("BindableFunction") then
		local ok, res = pcall(pe.Invoke, pe, anim)
		if ok and res ~= false then
			return true
		end
	end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		return false
	end
	local track = animator:LoadAnimation(anim)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
	local conn
	conn = hum.Running:Connect(function(speed)
		if speed > 0.5 then
			track:Stop(0.2)
			conn:Disconnect()
		end
	end)
	return true
end

function AC.LookupEmote(id)
	local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id)
	if not ok or not info then
		log(L("asset_missing", tostring(id)), true)
		return nil
	end
	if info.AssetTypeId ~= EMOTE_ASSET_TYPE then
		log(L("not_emote", tostring(info.Name)), true)
		return nil
	end
	return info.Name
end

function AC.ApplyBundle(bundleId, name)
	run(function()
		log(L("loading_avatar", name))
		local AssetService = game:GetService("AssetService")
		local ok, details = pcall(AssetService.GetBundleDetailsAsync, AssetService, bundleId)
		if not ok or not details then
			log(L("avatar_failed", tostring(details)), true)
			return
		end
		local outfitId
		for _, it in ipairs(details.Items) do
			if it.Type == "UserOutfit" and (it.Name == details.Name or not outfitId) then
				outfitId = it.Id
			end
		end
		if not outfitId then
			log(L("avatar_failed", "UserOutfit"), true)
			return
		end
		local okD, desc = pcall(Players.GetHumanoidDescriptionFromOutfitId, Players, outfitId)
		if not okD then
			log(L("avatar_failed", tostring(desc)), true)
			return
		end
		setSource({ desc = desc, label = name })
	end)
end


local function buildUI()

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local DATA_DIR = "AvatarChanger"

local T = {
	surface = Color3.fromHex("121212"),
	card = Color3.fromHex("161616"),
	raised = Color3.fromHex("1a1a1a"),
	control = Color3.fromHex("232323"),
	controlHover = Color3.fromHex("2c2c2c"),
	figure = Color3.fromHex("3a3a3a"),
	text1 = Color3.fromHex("ededed"),
	text2 = Color3.fromHex("9a9a98"),
	text3 = Color3.fromHex("5f5f5d"),
	accent = Color3.fromHex("e53945"),
	success = Color3.fromHex("3ecf8e"),
	info = Color3.fromHex("5b9cf6"),
	white = Color3.new(1, 1, 1),
	black = Color3.new(0, 0, 0),
}
local BORDER = { default = 0.9, subtle = 0.95, strong = 0.82 }

local function hasFile(path)
	local ok, r = pcall(isfile, path)
	return ok and r
end

local function asset(path)
	if getcustomasset and hasFile(path) then
		local ok, id = pcall(getcustomasset, path)
		if ok then
			return id
		end
	end
end

local FONT = {}
do
	local function family(name, faces)
		local t = { name = name, faces = {} }
		for _, f in ipairs(faces) do
			local id = asset(DATA_DIR .. "/fonts/" .. f[3])
			if not id then
				return nil
			end
			table.insert(t.faces, { name = f[1], weight = f[2], style = "normal", assetId = id })
		end
		local path = DATA_DIR .. "/fonts/" .. name .. ".json"
		pcall(writefile, path, HttpService:JSONEncode(t))
		return asset(path)
	end
	local inter = family("Inter", {
		{ "Regular", 400, "Inter-Regular.ttf" },
		{ "Medium", 500, "Inter-Medium.ttf" },
		{ "SemiBold", 600, "Inter-SemiBold.ttf" },
		{ "ExtraBold", 800, "Inter-ExtraBold.ttf" },
	})
	local mono = family("JetBrainsMono", { { "Regular", 400, "JetBrainsMono-Regular.ttf" } })
	local function pick(fam, fallback, weight)
		return if fam then Font.new(fam, weight) else Font.fromName(fallback, weight)
	end
	FONT.regular = pick(inter, "BuilderSans", Enum.FontWeight.Regular)
	FONT.medium = pick(inter, "BuilderSans", Enum.FontWeight.Medium)
	FONT.semibold = pick(inter, "BuilderSans", Enum.FontWeight.SemiBold)
	FONT.mono = pick(mono, "RobotoMono", Enum.FontWeight.Regular)
end

local ICON_GLYPH = {
	x = "×",
	minus = "–",
	plus = "+",
	["arrow-right"] = "→",
	refresh = "↻",
	user = "@",
	maximize = "⤢",
}


local CONFIG_PATH = DATA_DIR .. "/config.json"
local OUTFITS_PATH = DATA_DIR .. "/outfits.json"

local function readJson(path, default)
	if hasFile(path) then
		local ok, d = pcall(function()
			return HttpService:JSONDecode(readfile(path))
		end)
		if ok and type(d) == "table" then
			return d
		end
	end
	return default
end

local function writeJson(path, data)
	pcall(makefolder, DATA_DIR)
	pcall(writefile, path, HttpService:JSONEncode(data))
end

local config = readJson(CONFIG_PATH, {})
if config.persist ~= nil then
	AC.persist = config.persist
end
if config.useRules ~= nil then
	AC.useRules = config.useRules
end
local function saveConfig()
	writeJson(CONFIG_PATH, config)
end

local outfits = readJson(OUTFITS_PATH, {}).list or {}
local function saveOutfits()
	writeJson(OUTFITS_PATH, { list = outfits })
end

local function cleanLabel(s)
	return (s:gsub("%s*%b()$", ""))
end

local function plural(n, one, few, many)
	local m10, m100 = n % 10, n % 100
	if m10 == 1 and m100 ~= 11 then
		return one
	elseif m10 >= 2 and m10 <= 4 and (m100 < 12 or m100 > 14) then
		return few
	end
	return many
end


local function mk(class, props, children)
	local i = Instance.new(class)
	for k, v in pairs(props) do
		if k ~= "Parent" then
			i[k] = v
		end
	end
	for _, c in ipairs(children or {}) do
		c.Parent = i
	end
	if props.Parent then
		i.Parent = props.Parent
	end
	return i
end

local function corner(r)
	return mk("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function stroke(transparency, color, thickness)
	local s = mk("UIStroke", {
		Color = color or T.white,
		Transparency = transparency or BORDER.default,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
	pcall(function()
		s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end)
	return s
end

local SHADOW = {
	window = {
		Color = Color3.new(0, 0, 0),
		Transparency = 0.4,
		Offset = UDim2.fromOffset(0, 24),
		BlurRadius = UDim.new(0, 64),
		Spread = UDim2.fromOffset(-8, -8),
	},
	edge = { Inset = true, Color = Color3.new(1, 1, 1), Transparency = 0.94, Offset = UDim2.fromOffset(0, 1) },
	pop = {
		Color = Color3.new(0, 0, 0),
		Transparency = 0.45,
		Offset = UDim2.fromOffset(0, 8),
		BlurRadius = UDim.new(0, 24),
	},
	knob = {
		Color = Color3.new(0, 0, 0),
		Transparency = 0.5,
		Offset = UDim2.fromOffset(0, 1),
		BlurRadius = UDim.new(0, 3),
	},
	track = {
		Inset = true,
		Color = Color3.new(0, 0, 0),
		Transparency = 0.4,
		Offset = UDim2.fromOffset(0, 1),
		BlurRadius = UDim.new(0, 3),
	},
	accent = { Inset = true, Color = Color3.new(1, 1, 1), Transparency = 0.86, Offset = UDim2.fromOffset(0, -1) },
	card = { Inset = true, Color = Color3.new(0, 0, 0), Transparency = 0.5, BlurRadius = UDim.new(0, 18) },
	glow = { Color = Color3.fromHex("e53945"), Transparency = 0.7, BlurRadius = UDim.new(0, 10) },
}

local function shadow(parent, preset, z)
	local ok, s = pcall(Instance.new, "UIShadow")
	if not ok then
		return nil
	end
	for k, v in pairs(SHADOW[preset]) do
		pcall(function()
			s[k] = v
		end)
	end
	if z then
		s.ZIndex = z
	end
	s.Parent = parent
	return s
end

local function pad(t, r, b, l)
	return mk("UIPadding", {
		PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r or t),
		PaddingBottom = UDim.new(0, b or t),
		PaddingLeft = UDim.new(0, l or r or t),
	})
end

local function list(dir, gap, valign, halign)
	return mk("UIListLayout", {
		FillDirection = dir or Enum.FillDirection.Vertical,
		Padding = UDim.new(0, gap or 0),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = valign or Enum.VerticalAlignment.Top,
		HorizontalAlignment = halign or Enum.HorizontalAlignment.Left,
	})
end

local function label(props)
	props.BackgroundTransparency = 1
	props.FontFace = props.FontFace or FONT.regular
	props.TextColor3 = props.TextColor3 or T.text1
	props.TextSize = props.TextSize or 13
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return mk("TextLabel", props)
end

local ANIM_SPEED = 0.75

local function tween(inst, props, t, style, dir)
	local tw = TweenService:Create(
		inst,
		TweenInfo.new((t or 0.14) * ANIM_SPEED, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

local function icon(name, size, color, props)
	local id = asset(DATA_DIR .. "/assets/" .. name .. ".png")
	local base = { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 }
	for k, v in pairs(props or {}) do
		base[k] = v
	end
	if id then
		base.Image = id
		base.ImageColor3 = color
		return mk("ImageLabel", base)
	end
	base.Text = ICON_GLYPH[name] or "?"
	base.TextColor3 = color
	base.TextSize = size + 2
	base.FontFace = FONT.medium
	return mk("TextLabel", base)
end

local function tint(inst, color)
	if inst:IsA("ImageLabel") then
		tween(inst, { ImageColor3 = color })
	else
		tween(inst, { TextColor3 = color })
	end
end

local function pressable(btn, depth)
	local sc = mk("UIScale", { Parent = btn })
	local function up()
		tween(sc, { Scale = 1 }, 0.18, Enum.EasingStyle.Back)
	end
	btn.MouseButton1Down:Connect(function()
		tween(sc, { Scale = depth or 0.95 }, 0.07)
	end)
	btn.MouseButton1Up:Connect(up)
	btn.MouseLeave:Connect(up)
	return sc
end

local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
local sg = mk("ScreenGui", {
	Name = "TZAR_AvatarChanger",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 999,
	Parent = guiParent,
})
AC.gui = sg


local tooltip = mk("Frame", {
	Visible = false,
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundColor3 = T.control,
	ZIndex = 60,
	Parent = sg,
}, { corner(6), stroke(BORDER.subtle), pad(5, 8) })
local tooltipText = label({ AutomaticSize = Enum.AutomaticSize.XY, TextSize = 12, ZIndex = 61, Parent = tooltip })
shadow(tooltip, "pop")

local function showTooltip(text)
	tooltipText.Text = text
	local m = UserInputService:GetMouseLocation()
	tooltip.Position = UDim2.fromOffset(m.X + 12, m.Y + 14)
	tooltip.Visible = true
end

local function hideTooltip()
	tooltip.Visible = false
end

local menuCatcher = mk("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 49,
	Parent = sg,
})
local menu = mk("Frame", {
	Visible = false,
	Size = UDim2.fromOffset(180, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundColor3 = T.raised,
	ZIndex = 50,
	Parent = sg,
}, { corner(10), stroke(BORDER.default), pad(4), list(nil, 2) })
local menuScale = mk("UIScale", { Parent = menu })
shadow(menu, "pop")
shadow(menu, "edge")

local function closeMenu()
	menu.Visible = false
	menuCatcher.Visible = false
end
menuCatcher.MouseButton1Click:Connect(closeMenu)
menuCatcher.MouseButton2Click:Connect(closeMenu)

local function openMenu(items)
	for _, c in ipairs(menu:GetChildren()) do
		if c:IsA("GuiButton") then
			c:Destroy()
		end
	end
	for i, it in ipairs(items) do
		local color = it[3] and T.accent or T.text2
		local b = mk("TextButton", {
			Text = it[1],
			FontFace = FONT.regular,
			TextSize = 13,
			TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false,
			BackgroundColor3 = T.control,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			LayoutOrder = i,
			ZIndex = 51,
			Parent = menu,
		}, { corner(6), pad(0, 10) })
		b.MouseEnter:Connect(function()
			tween(b, { BackgroundTransparency = 0, TextColor3 = it[3] and T.accent or T.text1 })
		end)
		b.MouseLeave:Connect(function()
			tween(b, { BackgroundTransparency = 1, TextColor3 = color })
		end)
		b.MouseButton1Click:Connect(function()
			closeMenu()
			task.spawn(it[2])
		end)
	end
	local m = UserInputService:GetMouseLocation()
	local view = sg.AbsoluteSize
	local h = #items * 30 + 8
	menu.Position = UDim2.fromOffset(math.min(m.X, view.X - 188), math.min(m.Y, view.Y - h - 8))
	menuCatcher.Visible = true
	menu.Visible = true
	menuScale.Scale = 0.92
	tween(menuScale, { Scale = 1 }, 0.16, Enum.EasingStyle.Back)
	hideTooltip()
end

local toasts = mk("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -16, 1, -16),
	Size = UDim2.fromOffset(300, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	ZIndex = 40,
	Parent = sg,
}, { list(nil, 8, Enum.VerticalAlignment.Bottom) })

local tetoId = asset(DATA_DIR .. "/assets/teto.png")
local toastOrder = 0
local TOAST_KIND = {
	info = { T.info, nil, "AVATAR CHANGER" },
	success = { T.success, "toast_success" },
	error = { T.accent, "toast_error" },
	discord = { Color3.fromHex("5865F2"), nil, "DISCORD" },
}

local function toast(msg, kind, actions, duration)
	local k = TOAST_KIND[kind] or TOAST_KIND.info
	toastOrder += 1
	local holder = mk("CanvasGroup", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		LayoutOrder = toastOrder,
		ZIndex = 40,
		Parent = toasts,
	})
	local content = mk("Frame", {
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 40,
		Parent = holder,
	})
	if tetoId then
		mk("ImageLabel", {
			Image = tetoId,
			Size = UDim2.fromOffset(38, 38),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 42,
			Parent = content,
		})
	end
	local cardFrame = mk("Frame", {
		Position = UDim2.fromOffset(44, 0),
		Size = UDim2.new(1, -44, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = T.raised,
		ZIndex = 41,
		Parent = content,
	}, { corner(12), stroke(BORDER.default), pad(9, 12), list(nil, 5) })
	local head = mk("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, ZIndex = 41, Parent = cardFrame })
	mk("Frame", {
		Size = UDim2.fromOffset(6, 6),
		Position = UDim2.fromOffset(0, 3),
		BackgroundColor3 = k[1],
		ZIndex = 42,
		Parent = head,
	}, { corner(3) })
	label({
		Text = k[2] and L(k[2]) or k[3],
		FontFace = FONT.mono,
		TextSize = 10,
		TextColor3 = k[1],
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -60, 1, 0),
		ZIndex = 42,
		Parent = head,
	})
	label({
		Text = L("toast_now"),
		FontFace = FONT.mono,
		TextSize = 10,
		TextColor3 = T.text3,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 42,
		Parent = head,
	})
	label({
		Text = msg,
		TextSize = 13,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		ZIndex = 42,
		Parent = cardFrame,
	})
	local dismiss
	if actions then
		local row = mk("Frame", {
			Size = UDim2.new(1, 0, 0, 24),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			ZIndex = 42,
			Parent = cardFrame,
		}, { list(Enum.FillDirection.Horizontal, 6) })
		for i, a in ipairs(actions) do
			local b = mk("TextButton", {
				Text = a[1],
				FontFace = FONT.medium,
				TextSize = 12,
				TextColor3 = a[3] and T.white or T.text2,
				AutoButtonColor = false,
				BackgroundColor3 = a[3] and k[1] or T.control,
				Size = UDim2.fromOffset(0, 24),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = i,
				ZIndex = 43,
				Parent = row,
			}, { corner(6), pad(0, 10) })
			b.MouseButton1Click:Connect(function()
				task.spawn(a[2])
				dismiss()
			end)
		end
	end
	local kids = toasts:GetChildren()
	local count = 0
	for i = #kids, 1, -1 do
		if kids[i]:IsA("CanvasGroup") then
			count += 1
			if count > 3 then
				kids[i]:Destroy()
			end
		end
	end
	tween(holder, { GroupTransparency = 0 }, 0.22)
	tween(content, { Position = UDim2.fromOffset(0, 0) }, 0.32, Enum.EasingStyle.Quint)
	dismiss = function()
		if holder.Parent then
			tween(holder, { GroupTransparency = 1 }, 0.25)
			tween(content, { Position = UDim2.fromOffset(24, 0) }, 0.25)
			task.wait(0.25)
			holder:Destroy()
		end
	end
	task.delay(duration or (kind == "error" and 6 or 4), dismiss)
end

setStatus = function(msg, kind)
	if kind == true then
		kind = "error"
	end
	toast(msg, kind or "info")
end

local trList = {}
local function tr(inst, prop, key, ...)
	local args = table.pack(...)
	table.insert(trList, { inst = inst, prop = prop, key = key, args = args })
	inst[prop] = L(key, table.unpack(args, 1, args.n))
	return inst
end
local function applyTranslations()
	for _, e in ipairs(trList) do
		if e.inst.Parent then
			e.inst[e.prop] = L(e.key, table.unpack(e.args, 1, e.args.n))
		end
	end
end


local DEFAULT_IDLE = {
	R15 = "rbxassetid://507766388",
	R6 = "rbxassetid://180435571",
}

local function viewportCopy(model)
	local ok, clone = pcall(function()
		model.Archivable = true
		local c = model:Clone()
		if c and #c:GetChildren() > 0 then
			return c
		end
		for _, d in ipairs(model:GetDescendants()) do
			if not d.Archivable then
				d.Archivable = true
			end
		end
		return model:Clone()
	end)
	if not ok or not clone then
		return nil
	end
	local idle
	local an = clone:FindFirstChild("Animate")
	local iv = an and an:FindFirstChild("idle")
	local a = iv and iv:FindFirstChildOfClass("Animation")
	if a then
		idle = a.AnimationId
	end
	for _, d in ipairs(clone:GetDescendants()) do
		if d:IsA("LuaSourceContainer") or d:IsA("GuiBase") or d:IsA("Tool") or d:IsA("ForceField") then
			d:Destroy()
		elseif d:IsA("BasePart") then
			d.Anchored = d.Name == "HumanoidRootPart"
			d.CanCollide = false
		end
	end
	local hum = clone:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		idle = idle or DEFAULT_IDLE[hum.RigType.Name]
	end
	return clone, idle
end

local function newScene(parent, props)
	local vp = mk("ViewportFrame", {
		BackgroundTransparency = 1,
		Ambient = Color3.fromRGB(150, 150, 155),
		LightColor = Color3.fromRGB(255, 244, 236),
		LightDirection = Vector3.new(-0.5, -1, -0.9),
		Parent = parent,
	})
	for k, v in pairs(props or {}) do
		vp[k] = v
	end
	local wm = mk("WorldModel", { Parent = vp })
	local cam = mk("Camera", { FieldOfView = 28, Parent = vp })
	vp.CurrentCamera = cam
	local scene = { vp = vp, wm = wm, cam = cam, yaw = math.rad(-25), model = nil, track = nil }

	function scene:frame()
		if not self.center then
			return
		end
		local dir = (self.facing * CFrame.Angles(0, self.yaw, 0)).LookVector
		self.cam.CFrame = CFrame.lookAt(self.center + dir * self.dist, self.center)
	end

	function scene:set(model, zoom)
		if self.model then
			self.model:Destroy()
			self.model, self.track = nil, nil
		end
		self.animTracks, self.animTrack = {}, nil
		self.source = model
		if not model then
			return
		end
		local clone, idle = viewportCopy(model)
		if not clone then
			return
		end
		clone.Parent = self.wm
		local root = clone:FindFirstChild("HumanoidRootPart")
		local cf, size = clone:GetBoundingBox()
		self.facing = (root and root.CFrame or cf).Rotation
		self.center = cf.Position
		local aspect = math.max(self.vp.AbsoluteSize.X / math.max(self.vp.AbsoluteSize.Y, 1), 0.5)
		local h = math.max(size.Y, size.X / aspect, 3)
		self.dist = (h / 2) / math.tan(math.rad(self.cam.FieldOfView / 2)) * (zoom or 1.1)
		self.model, self.idle = clone, idle
		self:frame()
	end

	function scene:play()
		if self.track or not (self.model and self.idle) then
			if self.track and not self.track.IsPlaying then
				self.track:Play(0.2)
			end
			return
		end
		local hum = self.model:FindFirstChildOfClass("Humanoid")
		if not hum then
			return
		end
		local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
		local anim = Instance.new("Animation")
		anim.AnimationId = self.idle
		local ok, track = pcall(animator.LoadAnimation, animator, anim)
		if ok then
			track.Looped = true
			track:Play(0.2)
			self.track = track
		end
	end

	function scene:stop()
		if self.track then
			self.track:Stop(0.3)
		end
	end

	function scene:playAnim(anim)
		local hum = self.model and self.model:FindFirstChildOfClass("Humanoid")
		if not (hum and anim) then
			return
		end
		local tr = self.animTracks[anim]
		if not tr then
			local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
			local ok, t = pcall(animator.LoadAnimation, animator, anim)
			if not ok then
				return
			end
			tr = t
			tr.Looped = true
			self.animTracks[anim] = tr
		end
		if self.animTrack and self.animTrack ~= tr then
			self.animTrack:Stop(0.15)
		end
		if self.track then
			self.track:Stop(0.15)
		end
		self.animTrack = tr
		if not tr.IsPlaying then
			tr:Play(0.15)
		end
	end

	function scene:stopAnim()
		if self.animTrack then
			self.animTrack:Stop(0.2)
			self.animTrack = nil
		end
		self:play()
	end

	return scene
end

local function shimmer(parent)
	local f = mk("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.white,
		BackgroundTransparency = 0.94,
		ZIndex = 4,
		Parent = parent,
	}, { corner(7) })
	local g = mk("UIGradient", {
		Rotation = 20,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.2),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Offset = Vector2.new(-1, 0),
		Parent = f,
	})
	TweenService:Create(g, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
		Offset = Vector2.new(1, 0),
	}):Play()
	return f
end


local function iconButton(name, parent, props)
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = T.control,
		Parent = parent,
	}, { corner(7) })
	for k, v in pairs(props or {}) do
		b[k] = v
	end
	local ic = icon(name, 14, T.text2, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = b,
	})
	b.MouseEnter:Connect(function()
		tween(b, { BackgroundColor3 = T.controlHover })
		tint(ic, T.text1)
	end)
	b.MouseLeave:Connect(function()
		tween(b, { BackgroundColor3 = T.control })
		tint(ic, T.text2)
	end)
	pressable(b, 0.9)
	return b
end

local function switch(initial, onChange)
	local state = initial
	local track = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(30, 17),
		BackgroundColor3 = state and T.accent or T.control,
	}, { corner(9) })
	local knob = mk("Frame", {
		Size = UDim2.fromOffset(13, 13),
		Position = UDim2.fromOffset(state and 15 or 2, 2),
		BackgroundColor3 = state and T.white or T.text2,
		Parent = track,
	}, { corner(7) })
	shadow(track, "track")
	shadow(knob, "knob")
	track.MouseButton1Click:Connect(function()
		state = not state
		tween(track, { BackgroundColor3 = state and T.accent or T.control }, 0.18)
		tween(
			knob,
			{ Position = UDim2.fromOffset(state and 15 or 2, 2), BackgroundColor3 = state and T.white or T.text2 },
			0.22,
			Enum.EasingStyle.Back
		)
		onChange(state)
	end)
	return track
end

local function divider(order, parent)
	return mk("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = T.white,
		BackgroundTransparency = BORDER.subtle,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
end

local function eyebrow(text, parent, props)
	local l = label({
		Text = text,
		FontFace = FONT.medium,
		TextSize = 11,
		TextColor3 = T.text3,
		Size = UDim2.new(0.6, 0, 0, 14),
		Parent = parent,
	})
	for k, v in pairs(props or {}) do
		l[k] = v
	end
	return l
end

local function figure(parent, scale, colors)
	local f = mk("Frame", {
		Size = UDim2.fromOffset(46 * scale, 52 * scale),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = parent,
	})
	local function part(x, y, w, h, key)
		local c = colors and colors[key] and T.figure:Lerp(Color3.fromHex(colors[key]), 0.55) or T.figure
		mk("Frame", {
			Position = UDim2.fromOffset(x * scale, y * scale),
			Size = UDim2.fromOffset(w * scale, h * scale),
			BackgroundColor3 = c,
			Parent = f,
		}, { corner(math.max(2, 3 * scale)) })
	end
	part(16, 0, 14, 14, "HeadColor")
	part(10, 16, 26, 20, "TorsoColor")
	part(1, 16, 8, 20, "LeftArmColor")
	part(37, 16, 8, 20, "RightArmColor")
	part(11, 37, 11, 15, "LeftLegColor")
	part(24, 37, 11, 15, "RightLegColor")
	return f
end

local function makeDraggable(handle, target, onEnd)
	local dragging, startPos, startInput
	handle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging, startPos, startInput = true, target.Position, input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and dragging then
					dragging = false
					if onEnd then
						onEnd()
					end
				end
			end)
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if
			dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local d = input.Position - startInput
			target.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end


local W = 300
local INNER = W - 24
local function posFromConfig(c)
	if type(c) == "table" and #c == 4 then
		return UDim2.new(c[1], c[2], c[3], c[4])
	end
end
local startPos = posFromConfig(config.pos) or UDim2.new(1, -W - 24, 0, 80)

local win = mk("Frame", {
	Name = "Window",
	Size = UDim2.fromOffset(W, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Position = startPos,
	BackgroundColor3 = T.surface,
	Parent = sg,
}, { corner(14), stroke(BORDER.default), list() })
local winScale = mk("UIScale", { Parent = win })
shadow(win, "window", -2)
shadow(win, "edge")

local pill = mk("TextButton", {
	Name = "Pill",
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	Size = UDim2.fromOffset(0, 38),
	AutomaticSize = Enum.AutomaticSize.X,
	Position = startPos,
	BackgroundColor3 = T.surface,
	Parent = sg,
}, {
	corner(12),
	stroke(BORDER.default),
	pad(0, 6, 0, 12),
	list(Enum.FillDirection.Horizontal, 8, Enum.VerticalAlignment.Center),
})
local pillScale = mk("UIScale", { Parent = pill })
shadow(pill, "pop")
shadow(pill, "edge")

local function clampOnScreen(frame)
	local box, size = sg.AbsoluteSize, frame.AbsoluteSize
	local rel = frame.AbsolutePosition - sg.AbsolutePosition
	local m = 8
	local dx = math.clamp(rel.X, m, math.max(box.X - size.X - m, m)) - rel.X
	local dy = math.clamp(rel.Y, m, math.max(box.Y - size.Y - m, m)) - rel.Y
	if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then
		frame.Position += UDim2.fromOffset(math.round(dx), math.round(dy))
	end
end

local function savePos()
	local frame = if pill.Visible then pill else win
	local p = frame.Position
	config.pos = { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset }
	saveConfig()
end

local function settle()
	task.delay(0.32, function()
		local frame = if pill.Visible then pill else win
		if frame.Parent then
			clampOnScreen(frame)
			savePos()
		end
	end)
end

local function brand(parent, order)
	local logoId = asset(DATA_DIR .. "/assets/logo.png")
	if logoId then
		mk("ImageLabel", {
			Image = logoId,
			Size = UDim2.fromOffset(15, 17),
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Parent = parent,
		})
	end
	label({
		Text = "TZAR HUB",
		FontFace = FONT.semibold,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		LayoutOrder = order + 1,
		Parent = parent,
	})
end

local top = mk("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 40),
	BackgroundTransparency = 1,
	LayoutOrder = 1,
	Parent = win,
}, { pad(0, 8, 0, 12) })
local brandRow = mk("Frame", {
	Size = UDim2.new(1, -94, 1, 0),
	BackgroundTransparency = 1,
	Parent = top,
}, { list(Enum.FillDirection.Horizontal, 7, Enum.VerticalAlignment.Center) })
brand(brandRow, 1)
label({
	Text = "AVATAR",
	FontFace = FONT.mono,
	TextSize = 10,
	TextColor3 = T.text3,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 12),
	LayoutOrder = 3,
	Parent = brandRow,
})
local rigPill = mk("Frame", {
	Size = UDim2.fromOffset(0, 18),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = T.control,
	LayoutOrder = 4,
	Parent = brandRow,
}, { corner(9), pad(0, 7), list(Enum.FillDirection.Horizontal, 5, Enum.VerticalAlignment.Center) })
local rigDot = mk("Frame", { Size = UDim2.fromOffset(6, 6), BackgroundColor3 = T.success, Parent = rigPill }, { corner(3) })
local rigText = label({
	Text = "R15",
	FontFace = FONT.mono,
	TextSize = 10,
	TextColor3 = T.text2,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 12),
	LayoutOrder = 2,
	Parent = rigPill,
})
TweenService:Create(rigDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	BackgroundTransparency = 0.6,
}):Play()
local actions = mk("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.fromScale(1, 0.5),
	Size = UDim2.fromOffset(90, 26),
	BackgroundTransparency = 1,
	Parent = top,
}, { list(Enum.FillDirection.Horizontal, 6) })
local langBtn = iconButton("settings", actions, { LayoutOrder = 0 })
local minBtn = iconButton("minus", actions, { LayoutOrder = 1 })
local closeBtn = iconButton("x", actions, { LayoutOrder = 2 })
divider(2, win)

local tabBar = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundTransparency = 1,
	LayoutOrder = 3,
	Parent = win,
}, { pad(0, 12, 0, 12) })
local tabRow = mk("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Parent = tabBar,
}, { list(Enum.FillDirection.Horizontal, 16, Enum.VerticalAlignment.Center) })
local tabLine = mk("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.fromOffset(0, 2),
	BackgroundColor3 = T.accent,
	BorderSizePixel = 0,
	Parent = tabBar,
}, { corner(1) })
divider(4, win)

local body = mk("Frame", {
	Name = "Body",
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	LayoutOrder = 5,
	Parent = win,
}, { pad(12), list(nil, 10) })
local emotePage = mk("Frame", {
	Name = "Emotes",
	Visible = false,
	Size = UDim2.new(1, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	LayoutOrder = 5,
	Parent = win,
}, { pad(12), list(nil, 10) })

local tabs = {}
local activeTab = "look"
local sidePanel
local function placeTabLine(instant)
	local b = tabs[activeTab].button
	local x = b.AbsolutePosition.X - tabRow.AbsolutePosition.X
	local target = { Position = UDim2.new(0, x, 1, 0), Size = UDim2.fromOffset(b.AbsoluteSize.X, 2) }
	if instant then
		tabLine.Position, tabLine.Size = target.Position, target.Size
	else
		tween(tabLine, target, 0.25, Enum.EasingStyle.Quint)
	end
end
local function selectTab(name, instant)
	activeTab = name
	for n, t in pairs(tabs) do
		local on = n == name
		t.page.Visible = on
		tween(t.button, { TextColor3 = on and T.text1 or T.text2 })
	end
	placeTabLine(instant)
	config.tab = name
end
local function addTab(name, key, page, order)
	local b = mk("TextButton", {
		FontFace = FONT.medium,
		TextSize = 13,
		TextColor3 = T.text2,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 30),
		LayoutOrder = order,
		Parent = tabRow,
	})
	tr(b, "Text", key)
	tabs[name] = { button = b, page = page }
	b.MouseButton1Click:Connect(function()
		if sidePanel and activeTab ~= name then
			sidePanel.close()
		end
		selectTab(name)
		settle()
	end)
	b:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if activeTab == name then
			placeTabLine(true)
		end
	end)
end
addTab("look", "tab_look", body, 1)
addTab("emotes", "tab_emotes", emotePage, 2)

local rowA = mk("Frame", { Size = UDim2.new(1, 0, 0, 124), BackgroundTransparency = 1, LayoutOrder = 1, Parent = body })
local card = mk("Frame", {
	Size = UDim2.fromOffset(104, 124),
	BackgroundColor3 = T.card,
	ClipsDescendants = true,
	Parent = rowA,
}, { corner(12), stroke(BORDER.subtle) })
shadow(card, "card")
do
	local spot = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.58),
		Size = UDim2.fromScale(1.3, 1),
		BackgroundColor3 = T.white,
		Parent = card,
	})
	local g = mk("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.9),
			NumberSequenceKeypoint.new(0.55, 0.97),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = spot,
	})
	if not pcall(function()
		g.Type = Enum.GradientType.Radial
	end) then
		spot:Destroy()
	end
end
local mainScene = newScene(card, { Size = UDim2.new(1, 0, 1, 0) })
local previewFallback = figure(card, 1.1, nil)
local previewLoading = shimmer(card)
previewLoading.Visible = false
mk("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, 34),
	BackgroundColor3 = T.black,
	ZIndex = 2,
	Parent = card,
}, {
	mk("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0.25),
		}),
	}),
})
local previewName = label({
	Text = "",
	FontFace = FONT.medium,
	TextSize = 12,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Position = UDim2.new(0, 8, 1, -20),
	Size = UDim2.new(1, -40, 0, 14),
	ZIndex = 3,
	Parent = card,
})
local previewRig = label({
	Text = "",
	FontFace = FONT.mono,
	TextSize = 9,
	TextColor3 = T.text3,
	TextXAlignment = Enum.TextXAlignment.Right,
	Position = UDim2.new(1, -34, 1, -19),
	Size = UDim2.fromOffset(27, 12),
	ZIndex = 3,
	Parent = card,
})

local rightCol = mk("Frame", {
	Position = UDim2.fromOffset(114, 0),
	Size = UDim2.new(1, -114, 1, 0),
	BackgroundTransparency = 1,
	Parent = rowA,
})
tr(
	eyebrow("", rightCol, {
		Size = UDim2.new(1, 0, 0, 14),
		TextSize = 10,
		FontFace = FONT.mono,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}),
	"Text",
	"by_nick"
)
local inputBox = mk("Frame", {
	Position = UDim2.fromOffset(0, 20),
	Size = UDim2.new(1, 0, 0, 32),
	BackgroundColor3 = T.control,
	Parent = rightCol,
}, { corner(8) })
local inputStroke = stroke(BORDER.subtle)
inputStroke.Parent = inputBox
shadow(inputBox, "track")
local inputIcon = icon("user", 14, T.text3, { Position = UDim2.fromOffset(9, 9), Parent = inputBox })
local box = mk("TextBox", {
	Text = "",
	PlaceholderColor3 = T.text3,
	TextColor3 = T.text1,
	FontFace = FONT.regular,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	ClipsDescendants = true,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(29, 0),
	Size = UDim2.new(1, -36, 1, 0),
	Parent = inputBox,
})
tr(box, "PlaceholderText", "nick_placeholder")
box.Focused:Connect(function()
	tween(inputStroke, { Transparency = 0.6, Color = T.accent })
	tint(inputIcon, T.text1)
end)

local copyBtn = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	Position = UDim2.fromOffset(0, 58),
	Size = UDim2.new(1, 0, 0, 32),
	BackgroundColor3 = T.raised,
	Parent = rightCol,
}, { corner(8), stroke(BORDER.default) })
tr(
	label({
		FontFace = FONT.medium,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(11, 0),
		Size = UDim2.new(1, -46, 1, 0),
		Parent = copyBtn,
	}),
	"Text",
	"wear"
)
local arrowSq = mk("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -4, 0.5, 0),
	Size = UDim2.fromOffset(24, 24),
	BackgroundColor3 = T.accent,
	Parent = copyBtn,
}, { corner(6) })
shadow(arrowSq, "accent")
local arrowIcon = icon("arrow-right", 14, T.white, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Parent = arrowSq,
})
copyBtn.MouseEnter:Connect(function()
	tween(copyBtn, { BackgroundColor3 = T.control })
	tween(arrowIcon, { Position = UDim2.new(0.5, 3, 0.5, 0) }, 0.18, Enum.EasingStyle.Back)
end)
copyBtn.MouseLeave:Connect(function()
	tween(copyBtn, { BackgroundColor3 = T.raised })
	tween(arrowIcon, { Position = UDim2.fromScale(0.5, 0.5) }, 0.18)
end)
pressable(copyBtn, 0.97)

local resetBtn = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	Position = UDim2.fromOffset(0, 96),
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundColor3 = T.control,
	Parent = rightCol,
}, {
	corner(8),
	list(Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center, Enum.HorizontalAlignment.Center),
})
local resetIcon = icon("refresh", 13, T.text2, { LayoutOrder = 1, Parent = resetBtn })
local resetText = label({
	FontFace = FONT.medium,
	TextSize = 12,
	TextColor3 = T.text2,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 16),
	LayoutOrder = 2,
	Parent = resetBtn,
})
tr(resetText, "Text", "reset_look")
resetBtn.MouseEnter:Connect(function()
	tween(resetBtn, { BackgroundColor3 = T.controlHover })
	tint(resetIcon, T.text1)
	tween(resetText, { TextColor3 = T.text1 })
end)
resetBtn.MouseLeave:Connect(function()
	tween(resetBtn, { BackgroundColor3 = T.control })
	tint(resetIcon, T.text2)
	tween(resetText, { TextColor3 = T.text2 })
end)
pressable(resetBtn, 0.97)
resetBtn.MouseButton1Click:Connect(function()
	tween(resetIcon, { Rotation = resetIcon.Rotation - 360 }, 0.5, Enum.EasingStyle.Quint)
	task.spawn(AC.Reset)
end)

local function wear()
	if box.Text:match("%S") then
		task.spawn(AC.ApplyUser, box.Text)
	end
end
copyBtn.MouseButton1Click:Connect(wear)
box.FocusLost:Connect(function(enter)
	tween(inputStroke, { Transparency = BORDER.subtle, Color = T.white })
	tint(inputIcon, T.text3)
	if enter then
		wear()
	end
end)

local serverDivider = divider(2, body)
local server = mk("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, LayoutOrder = 3, Parent = body })
tr(eyebrow("", server), "Text", "on_server")
local serverCount = label({
	Text = "",
	FontFace = FONT.mono,
	TextSize = 10,
	TextColor3 = T.text3,
	TextXAlignment = Enum.TextXAlignment.Right,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 1),
	Size = UDim2.new(0.5, 0, 0, 12),
	Parent = server,
})
local chips = mk("Frame", {
	Position = UDim2.fromOffset(0, 18),
	Size = UDim2.new(1, 0, 0, 28),
	BackgroundTransparency = 1,
	Parent = server,
}, { list(Enum.FillDirection.Horizontal, 6) })

divider(4, body)
local outfitsSec = mk("Frame", { Size = UDim2.new(1, 0, 0, 120), BackgroundTransparency = 1, LayoutOrder = 5, Parent = body })
tr(eyebrow("", outfitsSec, { Position = UDim2.fromOffset(0, 1) }), "Text", "outfits")
local saveBtn = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),
	Size = UDim2.fromOffset(0, 16),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Parent = outfitsSec,
}, { list(Enum.FillDirection.Horizontal, 4, Enum.VerticalAlignment.Center) })
local saveIcon = icon("plus", 12, T.text2, { LayoutOrder = 1, Parent = saveBtn })
local saveText = label({
	Text = L("save"),
	FontFace = FONT.medium,
	TextSize = 12,
	TextColor3 = T.text2,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 16),
	LayoutOrder = 2,
	Parent = saveBtn,
})
tr(saveText, "Text", "save")
saveBtn.MouseEnter:Connect(function()
	tint(saveIcon, T.accent)
	tween(saveText, { TextColor3 = T.text1 })
	tween(saveIcon, { Rotation = 90 }, 0.25, Enum.EasingStyle.Back)
end)
saveBtn.MouseLeave:Connect(function()
	tint(saveIcon, T.text2)
	tween(saveText, { TextColor3 = T.text2 })
	tween(saveIcon, { Rotation = 0 }, 0.2)
end)
local tiles = mk("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 22),
	Size = UDim2.new(1, 0, 0, 98),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollingDirection = Enum.ScrollingDirection.X,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = T.text3,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	ElasticBehavior = Enum.ElasticBehavior.Never,
	Parent = outfitsSec,
}, { list(Enum.FillDirection.Horizontal, 6) })

local function edgeFade(right)
	local f = mk("Frame", {
		AnchorPoint = Vector2.new(right and 1 or 0, 0),
		Position = UDim2.new(right and 1 or 0, 0, 0, 22),
		Size = UDim2.fromOffset(28, 94),
		BackgroundColor3 = T.surface,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 5,
		Parent = outfitsSec,
	})
	mk("UIGradient", {
		Rotation = right and 0 or 180,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = f,
	})
	return f
end
local fadeLeft, fadeRight = edgeFade(false), edgeFade(true)
local function updateFades()
	local maxX = tiles.AbsoluteCanvasSize.X - tiles.AbsoluteWindowSize.X
	fadeLeft.Visible = tiles.CanvasPosition.X > 2
	fadeRight.Visible = maxX > 2 and tiles.CanvasPosition.X < maxX - 2
end
tiles:GetPropertyChangedSignal("CanvasPosition"):Connect(updateFades)
tiles:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateFades)

divider(6, body)
local toggles = mk("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 7, Parent = body })
local function toggleItem(key, initial, xScale, onChange, row)
	local holder = mk("Frame", {
		Position = UDim2.fromScale(xScale, 0),
		Size = UDim2.fromScale(0.48, 1),
		BackgroundTransparency = 1,
		Parent = row or toggles,
	}, { list(Enum.FillDirection.Horizontal, 7, Enum.VerticalAlignment.Center) })
	switch(initial, onChange).Parent = holder
	tr(
		label({
			FontFace = FONT.medium,
			TextSize = 12,
			TextColor3 = T.text2,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -37, 0, 16),
			LayoutOrder = 2,
			Parent = holder,
		}),
		"Text",
		key
	)
end
toggleItem("after_death", AC.persist, 0, function(v)
	AC.persist = v
	config.persist = v
	saveConfig()
end)
toggleItem("game_rules", AC.useRules, 0.52, function(v)
	config.useRules = v
	saveConfig()
	task.spawn(AC.SetRules, v)
end)

brand(pill, 1)
local pillName = label({
	Text = "",
	TextSize = 12,
	TextColor3 = T.text2,
	TextTruncate = Enum.TextTruncate.AtEnd,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 16),
	LayoutOrder = 3,
	Parent = pill,
})
mk("UISizeConstraint", { MaxSize = Vector2.new(130, 16), Parent = pillName })
local expandBtn = iconButton("maximize", pill, { LayoutOrder = 4 })

local function popIn(scale)
	scale.Scale = 0.92
	tween(scale, { Scale = 1 }, 0.28, Enum.EasingStyle.Back)
end

local function setCollapsed(on, instant)
	hideTooltip()
	if on then
		pill.Position = win.Position
		if not instant then
			tween(winScale, { Scale = 0.9 }, 0.12).Completed:Wait()
		end
		win.Visible = false
		pill.Visible = true
		popIn(pillScale)
	else
		win.Position = pill.Position
		pill.Visible = false
		win.Visible = true
		popIn(winScale)
	end
	config.collapsed = on
	settle()
end
minBtn.MouseButton1Click:Connect(function()
	setCollapsed(true)
end)
expandBtn.MouseButton1Click:Connect(function()
	setCollapsed(false)
end)
closeBtn.MouseButton1Click:Connect(function()
	tween(winScale, { Scale = 0.9 }, 0.12).Completed:Wait()
	AC.Destroy()
end)
makeDraggable(top, win, settle)
makeDraggable(pill, pill, settle)
sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(settle)


local function myDescription()
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		local ok, d = pcall(hum.GetAppliedDescription, hum)
		if ok then
			return d
		end
	end
end

local function myRig()
	local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
	return hum and hum.RigType or Enum.HumanoidRigType.R15
end

local function colorsOf(desc)
	if not desc then
		return nil
	end
	local ok, t = pcall(serializeDescription, desc)
	return ok and t.colors or nil
end

local lookCache = setmetatable({}, { __mode = "k" })
local function myLookModel()
	local char = lp.Character
	if not char then
		return nil
	end
	if AC.originals[char] then
		return AC.originals[char]
	end
	if not lookCache[char] then
		lookCache[char] = snapshot(char)
	end
	return lookCache[char]
end

local thumbCache = {}
local thumbQueue = {}
local thumbWaiters = {}
local thumbWorker = false

local function requestThumb(key, build, cb)
	local cached = thumbCache[key]
	if cached ~= nil then
		if cached then
			cb(cached)
		end
		return
	end
	if thumbWaiters[key] then
		table.insert(thumbWaiters[key], cb)
		return
	end
	thumbWaiters[key] = { cb }
	table.insert(thumbQueue, { key = key, build = build })
	if thumbWorker then
		return
	end
	thumbWorker = true
	task.spawn(function()
		while AC.alive and #thumbQueue > 0 do
			local job = table.remove(thumbQueue, 1)
			local ok, model = pcall(job.build)
			thumbCache[job.key] = ok and model or false
			for _, f in ipairs(thumbWaiters[job.key] or {}) do
				if ok and model then
					task.spawn(f, model)
				end
			end
			thumbWaiters[job.key] = nil
		end
		thumbWorker = false
	end)
end

local function outfitThumbKey(o)
	return o.id .. "|" .. myRig().Name .. "|" .. tostring(AC.useRules)
end

local function buildOutfitModel(o)
	return function()
		return (buildModel(deserializeDescription(o.data), myRig(), AC.useRules, {}))
	end
end


local spinning = false
local dragYaw = false
local lastPreviewModel

local function refreshPreview()
	local rig = myRig().Name
	rigText.Text = rig
	previewRig.Text = rig
	local src = AC.source
	local model
	if src and src.model then
		previewName.Text = cleanLabel(src.label)
		pillName.Text = cleanLabel(src.label)
		model = src.model
	else
		previewName.Text = lp.DisplayName
		pillName.Text = L("my_look")
		model = myLookModel()
	end
	if model == lastPreviewModel and mainScene.model then
		return
	end
	lastPreviewModel = model
	previewLoading.Visible = true
	mainScene:set(model, 1.05)
	previewLoading.Visible = false
	previewFallback.Visible = mainScene.model == nil
	if mainScene.model then
		mainScene:play()
		mainScene.vp.ImageTransparency = 1
		tween(mainScene.vp, { ImageTransparency = 0 }, 0.35)
		local target = math.rad(-25)
		mainScene.yaw = target - math.pi
		spinning = true
		local v = Instance.new("NumberValue")
		v.Value = mainScene.yaw
		v.Changed:Connect(function(y)
			mainScene.yaw = y
			mainScene:frame()
		end)
		local tw = tween(v, { Value = target }, 0.8, Enum.EasingStyle.Quint)
		tw.Completed:Connect(function()
			spinning = false
			v:Destroy()
		end)
	end
end

do
	local lastX
	mainScene.vp.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragYaw, lastX = true, input.Position.X
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragYaw = false
		end
	end)
	connect(UserInputService.InputChanged, function(input)
		if dragYaw and input.UserInputType == Enum.UserInputType.MouseMovement then
			mainScene.yaw -= (input.Position.X - lastX) * 0.012
			lastX = input.Position.X
			mainScene:frame()
		end
	end)
end


local function playerMenu(plr)
	openMenu({
		{ L("menu_as_server"), function() AC.CopyPlayer(plr) end },
		{ L("menu_profile"), function() AC.ApplyUser(tostring(plr.UserId)) end },
		{ L("menu_export"), function() AC.ExportPlayer(plr) end },
	})
end

local function chip(plr, order)
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = T.control,
		LayoutOrder = order,
		Parent = chips,
	}, { corner(7) })
	local st = stroke(BORDER.subtle)
	st.Parent = b
	local initials = (plr.DisplayName:gsub("[^%w]", "")):sub(1, 2):upper()
	label({
		Text = initials ~= "" and initials or "?",
		FontFace = FONT.medium,
		TextSize = 11,
		TextColor3 = T.text2,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = b,
	})
	local img = mk("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ImageTransparency = 1,
		Parent = b,
	}, { corner(7) })
	task.spawn(function()
		local ok, url = pcall(
			Players.GetUserThumbnailAsync,
			Players,
			plr.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size48x48
		)
		if ok and img.Parent then
			img.Image = url
			tween(img, { ImageTransparency = 0 }, 0.3)
		end
	end)
	if AC.source and AC.source.playerId == plr.UserId then
		st.Color = T.accent
		st.Transparency = 0
		shadow(b, "glow")
	end
	local sc = mk("UIScale", { Parent = b })
	b.MouseEnter:Connect(function()
		tween(sc, { Scale = 1.08 }, 0.18, Enum.EasingStyle.Back)
		showTooltip(plr.DisplayName .. "  @" .. plr.Name .. "   " .. L("rmb_menu"))
	end)
	b.MouseLeave:Connect(function()
		tween(sc, { Scale = 1 }, 0.15)
		hideTooltip()
	end)
	b.MouseButton1Down:Connect(function()
		tween(sc, { Scale = 0.94 }, 0.07)
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, { Scale = 1.08 }, 0.15, Enum.EasingStyle.Back)
	end)
	b.MouseButton1Click:Connect(function()
		hideTooltip()
		task.spawn(AC.CopyPlayer, plr)
	end)
	b.MouseButton2Click:Connect(function()
		playerMenu(plr)
	end)
end

local chipsSig
local function rebuildChips()
	local others = {}
	local sig = { AC.lang, tostring(AC.source and AC.source.playerId) }
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= lp then
			table.insert(others, p)
			table.insert(sig, p.UserId)
		end
	end
	sig = table.concat(sig, ",")
	if sig == chipsSig then
		return
	end
	chipsSig = sig
	for _, c in ipairs(chips:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local n = #others
	server.Visible = n > 0
	serverDivider.Visible = n > 0
	serverCount.Text = L("players", n)
	local slots = math.floor((INNER + 6) / 34)
	local shown = if n > slots then slots - 1 else n
	for i = 1, shown do
		chip(others[i], i)
	end
	if n > shown then
		local more = mk("TextButton", {
			Text = "+" .. (n - shown),
			FontFace = FONT.mono,
			TextSize = 10,
			TextColor3 = T.text2,
			AutoButtonColor = false,
			Size = UDim2.fromOffset(28, 28),
			BackgroundColor3 = T.surface,
			LayoutOrder = shown + 1,
			Parent = chips,
		}, { corner(7), stroke(BORDER.default) })
		pressable(more, 0.92)
		more.MouseButton1Click:Connect(function()
			local items = {}
			for i = shown + 1, n do
				local p = others[i]
				table.insert(items, {
					p.DisplayName,
					function()
						playerMenu(p)
					end,
				})
			end
			openMenu(items)
		end)
	end
end


local tileScenes = {}
local hoveredScene
local tileOrder = 0

local function tile(name, meta, colors, selected, modelOrRequest, onClick, menuItems)
	tileOrder += 1
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(70, 96),
		BackgroundTransparency = 1,
		LayoutOrder = tileOrder,
		Parent = tiles,
	})
	local sc = mk("UIScale", { Parent = b })
	local frameIn = mk("Frame", {
		Position = UDim2.fromOffset(2, 2),
		Size = UDim2.new(1, -4, 1, -4),
		BackgroundColor3 = T.surface,
		Parent = b,
	}, { corner(10) })
	local st = stroke(BORDER.subtle)
	st.Parent = frameIn
	local thumb = mk("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(1, -6, 0, 54),
		BackgroundColor3 = T.control,
		ClipsDescendants = true,
		Parent = frameIn,
	}, { corner(7) })
	local fallback = figure(thumb, 0.72, colors)
	local loading = shimmer(thumb)
	local scene = newScene(thumb, { Size = UDim2.fromScale(1, 1), ImageTransparency = 1 })
	table.insert(tileScenes, scene)
	local function show(model)
		if not thumb.Parent then
			return
		end
		scene:set(model, 1.0)
		loading:Destroy()
		if scene.model then
			fallback.Visible = false
			tween(scene.vp, { ImageTransparency = 0 }, 0.3)
		end
	end
	if typeof(modelOrRequest) == "Instance" then
		show(modelOrRequest)
	elseif type(modelOrRequest) == "function" then
		modelOrRequest(show)
	else
		loading:Destroy()
	end
	local nameLabel = label({
		Text = name,
		FontFace = FONT.medium,
		TextSize = 11,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(6, 61),
		Size = UDim2.new(1, -10, 0, 14),
		Parent = frameIn,
	})
	local metaLabel = label({
		Text = meta,
		FontFace = FONT.mono,
		TextSize = 8,
		TextColor3 = T.text3,
		Position = UDim2.fromOffset(6, 76),
		Size = UDim2.new(1, -10, 0, 10),
		Parent = frameIn,
	})
	local function setSelected(sel, animate)
		selected = sel
		local props = {
			BackgroundColor3 = sel and Color3.fromHex("1a1213") or T.surface,
		}
		local sprops = {
			Transparency = sel and 0 or BORDER.subtle,
			Color = sel and T.accent or T.white,
			Thickness = sel and 1.5 or 1,
		}
		if animate then
			tween(frameIn, props)
			tween(st, sprops)
		else
			frameIn.BackgroundColor3 = props.BackgroundColor3
			st.Transparency, st.Color, st.Thickness = sprops.Transparency, sprops.Color, sprops.Thickness
		end
		metaLabel.TextColor3 = sel and T.accent or T.text3
	end
	setSelected(selected)
	b.MouseEnter:Connect(function()
		if not selected then
			tween(st, { Transparency = BORDER.strong })
		end
		tween(sc, { Scale = 1.03 }, 0.18, Enum.EasingStyle.Back)
		hoveredScene = scene
		scene:play()
		showTooltip(name .. "   " .. L("rmb_menu"))
	end)
	b.MouseLeave:Connect(function()
		if not selected then
			tween(st, { Transparency = BORDER.subtle })
		end
		tween(sc, { Scale = 1 }, 0.15)
		if hoveredScene == scene then
			hoveredScene = nil
		end
		scene:stop()
		hideTooltip()
	end)
	b.MouseButton1Down:Connect(function()
		tween(sc, { Scale = 0.96 }, 0.07)
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, { Scale = 1.03 }, 0.15, Enum.EasingStyle.Back)
	end)
	b.MouseButton1Click:Connect(function()
		hideTooltip()
		task.spawn(onClick)
	end)
	b.MouseButton2Click:Connect(function()
		openMenu(menuItems(nameLabel))
	end)
	return { button = b, setSelected = setSelected }
end

local rebuildTiles

local function uniqueName(base)
	local taken = {}
	for _, o in ipairs(outfits) do
		taken[o.name] = true
	end
	if not taken[base] then
		return base
	end
	local i = 2
	while taken[base .. " " .. i] do
		i += 1
	end
	return base .. " " .. i
end

local function saveCurrent()
	local desc, name
	if AC.source and AC.source.desc then
		desc, name = AC.source.desc, cleanLabel(AC.source.label)
	else
		desc, name = myDescription(), lp.DisplayName
	end
	if not desc then
		log(L("nothing_to_save"), true)
		return
	end
	local o = { id = HttpService:GenerateGUID(false), name = uniqueName(name), data = serializeDescription(desc) }
	table.insert(outfits, o)
	saveOutfits()
	if AC.source then
		AC.source.outfitId = o.id
		if AC.source.model then
			thumbCache[outfitThumbKey(o)] = AC.source.model
		end
	end
	log(L("saved_outfit", o.name), "success")
	rebuildTiles()
end
saveBtn.MouseButton1Click:Connect(function()
	task.spawn(saveCurrent)
end)

local function renameInline(nameLabel, o)
	local tb = mk("TextBox", {
		Text = o.name,
		FontFace = FONT.medium,
		TextSize = 11,
		TextColor3 = T.text1,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		BackgroundColor3 = T.control,
		Position = nameLabel.Position - UDim2.fromOffset(3, 1),
		Size = nameLabel.Size + UDim2.fromOffset(6, 2),
		ZIndex = 5,
		Parent = nameLabel.Parent,
	}, { corner(4), pad(0, 3) })
	tb:CaptureFocus()
	tb.FocusLost:Connect(function()
		local new = tb.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if new ~= "" then
			o.name = new
			saveOutfits()
		end
		rebuildTiles()
	end)
end

local function applySaved(o)
	run(setSource, { desc = deserializeDescription(o.data), label = o.name, outfitId = o.id })
end

local tilesSig, tileCtl = nil, {}
rebuildTiles = function()
	local src = AC.source
	local sig = { AC.lang, tostring(myLookModel()) }
	if src and not src.outfitId then
		table.insert(sig, "copied:" .. tostring(src))
	end
	for _, o in ipairs(outfits) do
		table.insert(sig, o.id .. "=" .. o.name)
	end
	sig = table.concat(sig, "|")
	if sig == tilesSig then
		local i = 1
		tileCtl[1].setSelected(src == nil, true)
		if src and not src.outfitId then
			i += 1
			tileCtl[i].setSelected(true, true)
		end
		for _, o in ipairs(outfits) do
			i += 1
			tileCtl[i].setSelected(src ~= nil and src.outfitId == o.id, true)
		end
		return
	end
	tilesSig = sig
	for _, s in ipairs(tileScenes) do
		if s.model then
			s.model:Destroy()
		end
	end
	tileScenes, hoveredScene, tileCtl = {}, nil, {}
	for _, c in ipairs(tiles:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	tileOrder = 0
	local function add(ctl)
		table.insert(tileCtl, ctl)
	end
	add(tile(lp.DisplayName, L("meta_original"), colorsOf(myDescription()), src == nil, myLookModel(), function()
		AC.Reset()
	end, function()
		return {
			{
				L("menu_export"),
				function()
					local d = myDescription()
					if d then
						exportDescription(d, lp.Name)
					end
				end,
			},
		}
	end))
	if src and not src.outfitId then
		local name = cleanLabel(src.label)
		add(tile(name, L("meta_copied"), colorsOf(src.desc), true, src.model, function() end, function()
			return {
				{ L("save"), saveCurrent },
				{
					L("menu_export"),
					function()
						exportDescription(src.desc, name)
					end,
				},
			}
		end))
	end
	for idx, o in ipairs(outfits) do
		local selected = src ~= nil and src.outfitId == o.id
		local preview = function(show)
			if selected and src.model then
				show(src.model)
			else
				requestThumb(outfitThumbKey(o), buildOutfitModel(o), show)
			end
		end
		add(tile(o.name, L("meta_saved"), o.data.colors, selected, preview, function()
			applySaved(o)
		end, function(nameLabel)
			return {
				{ L("menu_wear"), function() applySaved(o) end },
				{ L("menu_export"), function() exportDescription(deserializeDescription(o.data), o.name) end },
				{ L("menu_rename"), function() renameInline(nameLabel, o) end },
				{
					L("menu_delete"),
					function()
						table.remove(outfits, table.find(outfits, o) or idx)
						saveOutfits()
						local cur = AC.source
						if cur and cur.outfitId == o.id then
							cur.outfitId = nil
						end
						log(L("deleted_outfit", o.name))
						rebuildTiles()
					end,
					true,
				},
			}
		end))
	end
end


local function emoteThumb(id)
	return "rbxthumb://type=Asset&id=" .. id .. "&w=150&h=150"
end

local function saveEmoteList()
	local t = {}
	for _, e in ipairs(AC.emoteList) do
		table.insert(t, { id = e.id, name = e.name })
	end
	config.emoteList = t
	config.emoteSlots = nil
	saveConfig()
end

if type(config.emoteList) == "table" then
	for _, e in ipairs(config.emoteList) do
		if tonumber(e.id) then
			AC.AddEmote(tonumber(e.id), e.name)
		end
	end
elseif type(config.emoteSlots) == "table" then
	for i = 1, 8 do
		local v = config.emoteSlots[tostring(i)]
		if type(v) == "table" and tonumber(v.id) then
			AC.AddEmote(tonumber(v.id), v.name)
		end
	end
	saveEmoteList()
end
if config.useOutfitEmotes ~= nil then
	AC.useOutfitEmotes = config.useOutfitEmotes
end

local function addEmoteToWheel(id, name)
	if AC.AddEmote(id, name) then
		saveEmoteList()
		log(L("emote_added", name), "success")
		if AC.onEmotesChanged then
			AC.onEmotesChanged()
		end
	else
		log(L("emote_exists", name))
	end
end

local function removeEmoteFromWheel(id, name)
	if AC.RemoveEmote(id) then
		saveEmoteList()
		log(L("emote_removed", name))
		if AC.onEmotesChanged then
			AC.onEmotesChanged()
		end
	end
end


sidePanel = (function()

local AvatarEditorService = game:GetService("AvatarEditorService")
local SIDE_W = 272
local CELL = UDim2.new(1 / 3, -7, 0, 92)

local panel = mk("Frame", {
	Name = "Side",
	Visible = false,
	Size = UDim2.fromOffset(SIDE_W, 400),
	BackgroundColor3 = T.surface,
	Parent = sg,
}, { corner(14), stroke(BORDER.default) })
shadow(panel, "window", -2)
shadow(panel, "edge")
local panelScale = mk("UIScale", { Parent = panel })

local head = mk("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Parent = panel }, { pad(0, 8, 0, 14) })
local title = eyebrow("", head, { Size = UDim2.new(1, -40, 1, 0) })
local closeSide = iconButton("x", head, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.fromScale(1, 0.5) })
mk("Frame", {
	Position = UDim2.fromOffset(0, 40),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = T.white,
	BackgroundTransparency = BORDER.subtle,
	BorderSizePixel = 0,
	Parent = panel,
})

local bodyFrame = mk("Frame", {
	Position = UDim2.fromOffset(0, 41),
	Size = UDim2.new(1, 0, 1, -41),
	BackgroundTransparency = 1,
	Parent = panel,
}, { pad(12) })

local searchBox = mk("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = T.control, Parent = bodyFrame }, { corner(8) })
local searchStroke = stroke(BORDER.subtle)
searchStroke.Parent = searchBox
shadow(searchBox, "track")
local searchIcon = icon("search", 14, T.text3, { Position = UDim2.fromOffset(9, 9), Parent = searchBox })
local input = mk("TextBox", {
	Text = "",
	PlaceholderColor3 = T.text3,
	TextColor3 = T.text1,
	FontFace = FONT.regular,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	ClipsDescendants = true,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(29, 0),
	Size = UDim2.new(1, -60, 1, 0),
	Parent = searchBox,
})
local clearBtn = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -5, 0.5, 0),
	Size = UDim2.fromOffset(22, 22),
	BackgroundColor3 = T.controlHover,
	BackgroundTransparency = 1,
	Visible = false,
	Parent = searchBox,
}, { corner(6) })
icon("x", 12, T.text3, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Parent = clearBtn })

local seg = mk("Frame", {
	Position = UDim2.fromOffset(0, 40),
	Size = UDim2.new(1, 0, 0, 26),
	BackgroundColor3 = T.control,
	Parent = bodyFrame,
}, { corner(8), pad(2), list(Enum.FillDirection.Horizontal, 2) })
shadow(seg, "track")

local results = mk("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 76),
	Size = UDim2.new(1, 0, 1, -76),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = T.text3,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = bodyFrame,
}, {
	mk("UIGridLayout", { CellSize = CELL, CellPadding = UDim2.fromOffset(10, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	pad(2, 2, 6, 2),
})
local note = label({
	TextSize = 12,
	TextColor3 = T.text3,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextWrapped = true,
	Position = UDim2.fromOffset(0, 76),
	Size = UDim2.new(1, 0, 0, 80),
	Visible = false,
	Parent = bodyFrame,
})

local MODES = {
	emotes = {
		title = "side_emotes",
		placeholder = "emote_search",
		segments = { "sort_popular", "sort_favorited", "sort_new" },
	},
	avatars = {
		title = "side_avatars",
		placeholder = "avatar_search",
		segments = { "mode_players", "mode_catalog", "mode_saved" },
	},
}
local SORTS = { Enum.CatalogSortType.Bestselling, Enum.CatalogSortType.MostFavorited, Enum.CatalogSortType.RecentlyCreated }

local opened, mode, segIndex = false, "emotes", 1
local segButtons = {}
local token, pages, loadingMore, noteKey = 0, nil, false, nil
local order = 0
local search

local function place()
	if not opened then
		return
	end
	local box = sg.AbsoluteSize
	local wp = win.AbsolutePosition - sg.AbsolutePosition
	local ws = win.AbsoluteSize
	local h = math.min(math.max(ws.Y, 380), box.Y - 16)
	local x
	if wp.X + ws.X + 8 + SIDE_W <= box.X - 8 then
		x = wp.X + ws.X + 8
	elseif wp.X - 8 - SIDE_W >= 8 then
		x = wp.X - 8 - SIDE_W
	else
		x = math.clamp(wp.X + ws.X - SIDE_W, 8, math.max(box.X - SIDE_W - 8, 8))
	end
	local y = math.clamp(wp.Y, 8, math.max(box.Y - h - 8, 8))
	panel.Position = UDim2.fromOffset(math.round(x), math.round(y))
	panel.Size = UDim2.fromOffset(SIDE_W, math.round(h))
end
win:GetPropertyChangedSignal("AbsolutePosition"):Connect(place)
win:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
win:GetPropertyChangedSignal("Visible"):Connect(function()
	panel.Visible = opened and win.Visible
end)

local function clear()
	for _, c in ipairs(results:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	order = 0
	results.CanvasPosition = Vector2.zero
	note.Visible = false
	noteKey = nil
end

local function showNote(key)
	noteKey = key
	note.Text = L(key)
	note.Visible = true
end

local function cell(image, text, sub, onClick, menuItems, dot)
	order += 1
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = T.control,
		LayoutOrder = order,
		Parent = results,
	}, { corner(10) })
	local st = stroke(BORDER.subtle)
	st.Parent = b
	if type(image) == "function" then
		local holder = mk("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Size = UDim2.fromOffset(60, 60),
			BackgroundColor3 = T.surface,
			ClipsDescendants = true,
			Parent = b,
		}, { corner(8) })
		image(holder)
	else
		local img = mk("ImageLabel", {
			Image = image,
			ImageTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 4),
			Size = UDim2.fromOffset(60, 60),
			BackgroundTransparency = 1,
			Parent = b,
		}, { corner(8) })
		tween(img, { ImageTransparency = 0 }, 0.3)
	end
	label({
		Text = text,
		TextSize = 10,
		TextColor3 = T.text1,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(4, 66),
		Size = UDim2.new(1, -8, 0, 12),
		Parent = b,
	})
	if sub then
		label({
			Text = sub,
			FontFace = FONT.mono,
			TextSize = 8,
			TextColor3 = T.text3,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(4, 78),
			Size = UDim2.new(1, -8, 0, 10),
			Parent = b,
		})
	end
	local mark = mk("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5, 0, 5),
		Size = UDim2.fromOffset(8, 8),
		BackgroundColor3 = T.accent,
		Visible = dot == true,
		ZIndex = 3,
		Parent = b,
	}, { corner(4) })
	local sc = mk("UIScale", { Parent = b })
	b.MouseEnter:Connect(function()
		tween(st, { Transparency = BORDER.strong })
		tween(sc, { Scale = 1.04 }, 0.18, Enum.EasingStyle.Back)
		showTooltip(text .. "   " .. L("rmb_menu"))
	end)
	b.MouseLeave:Connect(function()
		tween(st, { Transparency = BORDER.subtle })
		tween(sc, { Scale = 1 }, 0.15)
		hideTooltip()
	end)
	b.MouseButton1Down:Connect(function()
		tween(sc, { Scale = 0.95 }, 0.07)
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, { Scale = 1.04 }, 0.15, Enum.EasingStyle.Back)
	end)
	b.MouseButton1Click:Connect(function()
		hideTooltip()
		task.spawn(onClick, mark)
	end)
	b.MouseButton2Click:Connect(function()
		openMenu(menuItems(mark))
	end)
end

local function skeleton(n)
	for _ = 1, n do
		order += 1
		local f = mk("Frame", { BackgroundColor3 = T.control, LayoutOrder = order, Parent = results }, { corner(10) })
		shimmer(f)
	end
end

local function emoteCell(id, name)
	cell(emoteThumb(id), name, nil, function(mark)
		addEmoteToWheel(id, name)
		mark.Visible = true
	end, function(mark)
		local items = {
			{ L("menu_play"), function() AC.PlayEmote(id) end },
		}
		if AC.HasEmote(id) then
			table.insert(items, {
				L("menu_remove"),
				function()
					removeEmoteFromWheel(id, name)
					mark.Visible = false
				end,
				true,
			})
		else
			table.insert(items, 1, {
				L("menu_add_wheel"),
				function()
					addEmoteToWheel(id, name)
					mark.Visible = true
				end,
			})
		end
		return items
	end, AC.HasEmote(id))
end

local function wearAndSave(apply)
	return function()
		apply()
		saveCurrent()
	end
end

local function playerCell(userId, display, name)
	local thumb = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
	local function wear()
		AC.ApplyUser(tostring(userId))
	end
	cell(thumb, display, "@" .. name, wear, function()
		return {
			{ L("menu_wear"), wear },
			{ L("menu_wear_save"), wearAndSave(wear) },
		}
	end)
end

local function bundleCell(bundleId, name)
	local thumb = "rbxthumb://type=BundleThumbnail&id=" .. bundleId .. "&w=150&h=150"
	local function wear()
		AC.ApplyBundle(bundleId, name)
	end
	cell(thumb, name, nil, wear, function()
		return {
			{ L("menu_wear"), wear },
			{ L("menu_wear_save"), wearAndSave(wear) },
		}
	end)
end

local function savedCell(o)
	local function wear()
		applySaved(o)
	end
	cell(function(holder)
		local scene = newScene(holder, { Size = UDim2.fromScale(1, 1), ImageTransparency = 1 })
		requestThumb(outfitThumbKey(o), buildOutfitModel(o), function(model)
			if holder.Parent then
				scene:set(model, 1.0)
				tween(scene.vp, { ImageTransparency = 0 }, 0.3)
			end
		end)
	end, o.name, L("meta_saved"), wear, function()
		return {
			{ L("menu_wear"), wear },
			{
				L("menu_export"),
				function()
					exportDescription(deserializeDescription(o.data), o.name)
				end,
			},
		}
	end)
end

local function savedSearch(text)
	clear()
	local q = text:lower()
	local any = false
	for _, o in ipairs(outfits) do
		if q == "" or o.name:lower():find(q, 1, true) then
			any = true
			savedCell(o)
		end
	end
	if not any then
		showNote("search_nothing")
	end
end

local function appendCatalog(items)
	for _, it in ipairs(items) do
		if it.Id and it.Name then
			if mode == "emotes" then
				emoteCell(it.Id, it.Name)
			else
				bundleCell(it.Id, it.Name)
			end
		end
	end
end

local function catalogSearch(text, my)
	local ok, pg = pcall(function()
		local p = CatalogSearchParams.new()
		if mode == "emotes" then
			p.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
			p.SortType = SORTS[segIndex]
		else
			p.BundleTypes = { Enum.BundleType.BodyParts }
			p.SortType = Enum.CatalogSortType.Bestselling
		end
		if text:match("%S") then
			p.SearchKeyword = text
		end
		return AvatarEditorService:SearchCatalog(p)
	end)
	if my ~= token then
		return
	end
	clear()
	if not ok then
		showNote("search_failed")
		return
	end
	pages = pg
	local items = pg:GetCurrentPage()
	if #items == 0 then
		showNote("search_nothing")
	end
	appendCatalog(items)
end

local function playerSearch(text, my)
	if not text:match("%S") then
		clear()
		local any = false
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				any = true
				playerCell(p.UserId, p.DisplayName, p.Name)
			end
		end
		if not any then
			showNote("type_nick")
		end
		return
	end
	local ok, data = pcall(function()
		local r = request({
			Url = "https://users.roblox.com/v1/users/search?limit=25&keyword=" .. HttpService:UrlEncode(text),
			Method = "GET",
		})
		return HttpService:JSONDecode(r.Body)
	end)
	if my ~= token then
		return
	end
	clear()
	local list = ok and data and data.data
	if not list then
		local okId, id = pcall(Players.GetUserIdFromNameAsync, Players, text)
		if my ~= token then
			return
		end
		if okId and id then
			playerCell(id, text, text)
		else
			showNote("search_nothing")
		end
		return
	end
	if #list == 0 then
		showNote("search_nothing")
	end
	for _, u in ipairs(list) do
		playerCell(u.id, u.displayName or u.name, u.name)
	end
end

search = function(text)
	token += 1
	local my = token
	pages, loadingMore = nil, false
	if mode == "avatars" and segIndex == 3 then
		savedSearch(text)
		return
	end
	clear()
	skeleton(6)
	task.spawn(function()
		if mode == "emotes" then
			local id = tonumber(text:match("(%d%d%d%d%d+)"))
			if id and (not text:match("%a%a%a") or text:find("roblox.com", 1, true)) then
				local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id)
				if my ~= token then
					return
				end
				clear()
				if ok and info and info.AssetTypeId == EMOTE_ASSET_TYPE then
					emoteCell(id, info.Name)
				else
					showNote("search_nothing")
				end
				return
			end
			catalogSearch(text, my)
		elseif segIndex == 1 then
			playerSearch(text, my)
		else
			catalogSearch(text, my)
		end
	end)
end

local function loadMore()
	if not pages or loadingMore or pages.IsFinished then
		return
	end
	loadingMore = true
	local my = token
	task.spawn(function()
		local ok = pcall(pages.AdvanceToNextPageAsync, pages)
		if ok and my == token then
			appendCatalog(pages:GetCurrentPage())
		end
		loadingMore = false
	end)
end
results:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	if results.CanvasPosition.Y + results.AbsoluteWindowSize.Y >= results.AbsoluteCanvasSize.Y - 80 then
		loadMore()
	end
end)

local function paintSeg()
	for i, b in ipairs(segButtons) do
		local on = i == segIndex
		tween(b, { BackgroundTransparency = on and 0 or 1, TextColor3 = on and T.surface or T.text2 })
	end
end

local function buildSeg()
	for _, b in ipairs(segButtons) do
		b:Destroy()
	end
	segButtons = {}
	local segs = MODES[mode].segments
	for i, key in ipairs(segs) do
		local b = mk("TextButton", {
			Text = L(key),
			FontFace = FONT.medium,
			TextSize = 12,
			TextColor3 = T.text2,
			AutoButtonColor = false,
			BackgroundColor3 = T.text1,
			BackgroundTransparency = 1,
			Size = UDim2.new(1 / #segs, -2, 1, 0),
			LayoutOrder = i,
			Parent = seg,
		}, { corner(6) })
		segButtons[i] = b
		b.MouseButton1Click:Connect(function()
			segIndex = i
			paintSeg()
			search(input.Text)
		end)
	end
	paintSeg()
end

local typed = 0
input:GetPropertyChangedSignal("Text"):Connect(function()
	clearBtn.Visible = input.Text ~= ""
	typed += 1
	local my = typed
	task.delay(0.25, function()
		if my == typed and opened then
			search(input.Text)
		end
	end)
end)
input.Focused:Connect(function()
	tween(searchStroke, { Transparency = 0.6, Color = T.accent })
	tint(searchIcon, T.text1)
end)
input.FocusLost:Connect(function(enter)
	tween(searchStroke, { Transparency = BORDER.subtle, Color = T.white })
	tint(searchIcon, T.text3)
	if enter then
		search(input.Text)
	end
end)
clearBtn.MouseButton1Click:Connect(function()
	input.Text = ""
end)

local function close()
	if not opened then
		return
	end
	opened = false
	token += 1
	local tw = tween(panelScale, { Scale = 0.94 }, 0.12)
	tw.Completed:Connect(function()
		if not opened then
			panel.Visible = false
		end
	end)
end
closeSide.MouseButton1Click:Connect(close)

local function relabel()
	title.Text = L(MODES[mode].title)
	input.PlaceholderText = L(MODES[mode].placeholder)
	for i, key in ipairs(MODES[mode].segments) do
		if segButtons[i] then
			segButtons[i].Text = L(key)
		end
	end
	if note.Visible and noteKey then
		note.Text = L(noteKey)
	end
end

local function open(newMode, query, focus, segment)
	local changed = newMode ~= mode or not opened or (segment ~= nil and segment ~= segIndex)
	local rebuild = newMode ~= mode or not opened
	mode = newMode
	if rebuild then
		segIndex = segment or 1
		buildSeg()
	elseif segment and segment ~= segIndex then
		segIndex = segment
		paintSeg()
	end
	relabel()
	if query ~= nil then
		input.Text = query
	end
	if not opened then
		opened = true
		panel.Visible = win.Visible
		place()
		panelScale.Scale = 0.94
		tween(panelScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Back)
	end
	if changed or query ~= nil then
		search(input.Text)
	end
	if focus then
		input:CaptureFocus()
	end
end

return {
	open = open,
	close = close,
	isOpen = function()
		return opened
	end,
	mode = function()
		return mode
	end,
	setQuery = function(text)
		if opened and input.Text ~= text then
			input.Text = text
		end
	end,
	relabel = relabel,
}

end)()

do
	local hdr = mk("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Parent = outfitsSec,
	}, { list(Enum.FillDirection.Horizontal, 12, Enum.VerticalAlignment.Center) })
	saveBtn.AnchorPoint = Vector2.zero
	saveBtn.Position = UDim2.new()
	saveBtn.LayoutOrder = 2
	saveBtn.Parent = hdr
	local findBtn = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(0, 16),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = hdr,
	}, { list(Enum.FillDirection.Horizontal, 4, Enum.VerticalAlignment.Center) })
	local findIcon = icon("search", 12, T.text2, { LayoutOrder = 1, Parent = findBtn })
	local findText = tr(
		label({
			FontFace = FONT.medium,
			TextSize = 12,
			TextColor3 = T.text2,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 16),
			LayoutOrder = 2,
			Parent = findBtn,
		}),
		"Text",
		"find"
	)
	findBtn.MouseEnter:Connect(function()
		tint(findIcon, T.accent)
		tween(findText, { TextColor3 = T.text1 })
	end)
	findBtn.MouseLeave:Connect(function()
		tint(findIcon, T.text2)
		tween(findText, { TextColor3 = T.text2 })
	end)
	findBtn.MouseButton1Click:Connect(function()
		sidePanel.open("avatars", "", true, 3)
	end)
	box.Focused:Connect(function()
		sidePanel.open("avatars", box.Text)
	end)
	box:GetPropertyChangedSignal("Text"):Connect(function()
		if sidePanel.isOpen() and sidePanel.mode() == "avatars" then
			sidePanel.setQuery(box.Text)
		end
	end)
end


local emotes = (function()

local StarterGui = game:GetService("StarterGui")
local AvatarEditorService = game:GetService("AvatarEditorService")
local customWheel = config.customWheel ~= false

local function setNativeWheel(enabled)
	pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.EmotesMenu, enabled)
end

local rebuildEmotes
local openWheel

local emoteHead = mk("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1, Parent = emotePage })
local countLabel = eyebrow("", emoteHead, { Position = UDim2.fromOffset(0, 1) })
local addBtn = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),
	Size = UDim2.fromOffset(0, 16),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
	Parent = emoteHead,
}, { list(Enum.FillDirection.Horizontal, 4, Enum.VerticalAlignment.Center) })
local addIcon = icon("plus", 12, T.text2, { LayoutOrder = 1, Parent = addBtn })
local addText = tr(
	label({
		FontFace = FONT.medium,
		TextSize = 12,
		TextColor3 = T.text2,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 16),
		LayoutOrder = 2,
		Parent = addBtn,
	}),
	"Text",
	"add"
)
addBtn.MouseEnter:Connect(function()
	tint(addIcon, T.accent)
	tween(addText, { TextColor3 = T.text1 })
	tween(addIcon, { Rotation = 90 }, 0.25, Enum.EasingStyle.Back)
end)
addBtn.MouseLeave:Connect(function()
	tint(addIcon, T.text2)
	tween(addText, { TextColor3 = T.text2 })
	tween(addIcon, { Rotation = 0 }, 0.2)
end)
addBtn.MouseButton1Click:Connect(function()
	sidePanel.open("emotes", nil, true)
end)

local grid = mk("ScrollingFrame", {
	Size = UDim2.new(1, 0, 0, 124),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = T.text3,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	LayoutOrder = 2,
	Parent = emotePage,
}, {
	mk("UIGridLayout", {
		CellSize = UDim2.fromOffset(64, 56),
		CellPadding = UDim2.fromOffset(6, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
	pad(2, 0, 2, 0),
})

local function emoteTile(i, e)
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = T.control,
		LayoutOrder = i,
		Parent = grid,
	}, { corner(10) })
	local st = stroke(BORDER.subtle)
	st.Parent = b
	label({
		Text = tostring(i),
		FontFace = FONT.mono,
		TextSize = 9,
		TextColor3 = T.text3,
		Position = UDim2.fromOffset(6, 4),
		Size = UDim2.fromOffset(16, 10),
		ZIndex = 2,
		Parent = b,
	})
	if e.fromOutfit then
		mk("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -5, 0, 5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = T.info,
			ZIndex = 2,
			Parent = b,
		}, { corner(3) })
	end
	mk("ImageLabel", {
		Image = emoteThumb(e.id),
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.fromOffset(34, 34),
		BackgroundTransparency = 1,
		Parent = b,
	})
	label({
		Text = e.name,
		TextSize = 10,
		TextColor3 = T.text2,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(4, 40),
		Size = UDim2.new(1, -8, 0, 12),
		Parent = b,
	})
	local sc = mk("UIScale", { Parent = b })
	b.MouseEnter:Connect(function()
		tween(st, { Transparency = BORDER.strong })
		tween(sc, { Scale = 1.05 }, 0.18, Enum.EasingStyle.Back)
		showTooltip(e.name .. (e.fromOutfit and ("  · " .. L("tag_outfit")) or "") .. "   " .. L("rmb_menu"))
	end)
	b.MouseLeave:Connect(function()
		tween(st, { Transparency = BORDER.subtle })
		tween(sc, { Scale = 1 }, 0.15)
		hideTooltip()
	end)
	b.MouseButton1Down:Connect(function()
		tween(sc, { Scale = 0.95 }, 0.07)
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, { Scale = 1.05 }, 0.15, Enum.EasingStyle.Back)
	end)
	b.MouseButton1Click:Connect(function()
		task.spawn(AC.PlayEmote, e.id)
	end)
	b.MouseButton2Click:Connect(function()
		local items = { { L("menu_play"), function() AC.PlayEmote(e.id) end } }
		if e.fromOutfit then
			if not AC.HasEmote(e.id) then
				table.insert(items, { L("menu_add_wheel"), function() addEmoteToWheel(e.id, e.name) end })
			end
		else
			table.insert(items, {
				L("menu_front"),
				function()
					AC.MoveEmoteToFront(e.id)
					saveEmoteList()
					rebuildEmotes()
				end,
			})
			table.insert(items, { L("menu_remove"), function() removeEmoteFromWheel(e.id, e.name) end, true })
		end
		openMenu(items)
	end)
end

local function plusTile(i)
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = T.surface,
		LayoutOrder = i,
		Parent = grid,
	}, { corner(10) })
	local st = stroke(BORDER.default)
	st.Parent = b
	icon("plus", 16, T.text3, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Parent = b })
	label({
		Text = L("add"),
		TextSize = 10,
		TextColor3 = T.text3,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(4, 40),
		Size = UDim2.new(1, -8, 0, 12),
		Parent = b,
	})
	b.MouseEnter:Connect(function()
		tween(st, { Transparency = BORDER.strong })
	end)
	b.MouseLeave:Connect(function()
		tween(st, { Transparency = BORDER.default })
	end)
	b.MouseButton1Click:Connect(function()
		sidePanel.open("emotes", nil, true)
	end)
	pressable(b, 0.95)
end

divider(3, emotePage)
local emoteToggles = mk("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = 4, Parent = emotePage })
toggleItem("from_outfit", AC.useOutfitEmotes, 0, function(v)
	AC.useOutfitEmotes = v
	config.useOutfitEmotes = v
	saveConfig()
	rebuildEmotes()
end, emoteToggles)
toggleItem("own_wheel", customWheel, 0.52, function(v)
	customWheel = v
	config.customWheel = v
	saveConfig()
	setNativeWheel(not v)
end, emoteToggles)

local wheelBtn = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.new(1, 0, 0, 30),
	BackgroundColor3 = T.raised,
	LayoutOrder = 5,
	Parent = emotePage,
}, { corner(8), stroke(BORDER.default) })
tr(
	label({
		FontFace = FONT.medium,
		TextSize = 12,
		Position = UDim2.fromOffset(11, 0),
		Size = UDim2.new(1, -46, 1, 0),
		Parent = wheelBtn,
	}),
	"Text",
	"open_wheel"
)
local wheelSq = mk("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -4, 0.5, 0),
	Size = UDim2.fromOffset(22, 22),
	BackgroundColor3 = T.accent,
	Parent = wheelBtn,
}, { corner(6) })
shadow(wheelSq, "accent")
label({
	Text = ".",
	FontFace = FONT.mono,
	TextSize = 14,
	TextColor3 = T.white,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(1, 0.8),
	Parent = wheelSq,
})
wheelBtn.MouseEnter:Connect(function()
	tween(wheelBtn, { BackgroundColor3 = T.control })
end)
wheelBtn.MouseLeave:Connect(function()
	tween(wheelBtn, { BackgroundColor3 = T.raised })
end)
pressable(wheelBtn, 0.97)
wheelBtn.MouseButton1Click:Connect(function()
	openWheel()
end)

tr(
	label({
		FontFace = FONT.mono,
		TextSize = 9,
		TextColor3 = T.text3,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 0, 10),
		LayoutOrder = 6,
		Parent = emotePage,
	}),
	"Text",
	"wheel_keys"
)

local emotesSig
rebuildEmotes = function()
	local list = AC.GetWheelEmotes()
	local sig = { AC.lang }
	for _, e in ipairs(list) do
		table.insert(sig, e.id .. (e.fromOutfit and "o" or ""))
	end
	sig = table.concat(sig, ",")
	if sig == emotesSig then
		return
	end
	emotesSig = sig
	for _, c in ipairs(grid:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	for i, e in ipairs(list) do
		emoteTile(i, e)
	end
	plusTile(#list + 1)
	countLabel.Text = L("wheel_count", #list)
end
AC.onEmotesChanged = function()
	rebuildEmotes()
end


local wheelSg = mk("ScreenGui", {
	Name = "TZAR_EmoteWheel",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 1000,
	Enabled = false,
	Parent = guiParent,
})
AC.wheelGui = wheelSg
local dim = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = T.black,
	BackgroundTransparency = 1,
	Parent = wheelSg,
})
local hubHolder = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(0, 0),
	BackgroundTransparency = 1,
	Parent = wheelSg,
})
local hubScale = mk("UIScale", { Parent = hubHolder })
local hub = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(172, 172),
	BackgroundColor3 = T.surface,
	Parent = hubHolder,
}, { corner(86), stroke(BORDER.default) })
shadow(hub, "pop")
shadow(hub, "edge")
mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.6),
	Size = UDim2.fromScale(0.9, 0.8),
	BackgroundColor3 = T.white,
	Parent = hub,
}, {
	mk("UIGradient", {
		Type = Enum.GradientType.Radial,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.9),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}),
})
local preview = newScene(hub, { Size = UDim2.fromScale(1, 1) })

local hubTitle = label({
	FontFace = FONT.semibold,
	TextSize = 14,
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextXAlignment = Enum.TextXAlignment.Center,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(0, 192),
	Size = UDim2.fromOffset(300, 18),
	Parent = hubHolder,
})
local pager = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(0, 222),
	Size = UDim2.fromOffset(96, 26),
	BackgroundColor3 = T.surface,
	Parent = hubHolder,
}, { corner(13), stroke(BORDER.default) })
local pageLabel = label({
	FontFace = FONT.mono,
	TextSize = 10,
	TextColor3 = T.text2,
	TextXAlignment = Enum.TextXAlignment.Center,
	Size = UDim2.fromScale(1, 1),
	Parent = pager,
})
local function arrow(text, x)
	local b = mk("TextButton", {
		Text = text,
		FontFace = FONT.medium,
		TextSize = 16,
		TextColor3 = T.text2,
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(x < 0 and 0 or 1, 0.5),
		Position = UDim2.new(x < 0 and 0 or 1, x < 0 and 2 or -2, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = T.control,
		BackgroundTransparency = 1,
		Parent = pager,
	}, { corner(11) })
	b.MouseEnter:Connect(function()
		tween(b, { BackgroundTransparency = 0, TextColor3 = T.text1 })
	end)
	b.MouseLeave:Connect(function()
		tween(b, { BackgroundTransparency = 1, TextColor3 = T.text2 })
	end)
	return b
end
local prevBtn = arrow("‹", -34)
local nextBtn = arrow("›", 34)

local wheelSearch = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(0, -212),
	Size = UDim2.fromOffset(240, 36),
	BackgroundColor3 = T.surface,
	Parent = hubHolder,
}, { corner(18), stroke(BORDER.default) })
shadow(wheelSearch, "pop")
local wsStroke = wheelSearch:FindFirstChildOfClass("UIStroke")
icon("search", 14, T.text3, { Position = UDim2.fromOffset(13, 11), Parent = wheelSearch })
local wheelInput = mk("TextBox", {
	Text = "",
	PlaceholderColor3 = T.text3,
	TextColor3 = T.text1,
	FontFace = FONT.regular,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	ClipsDescendants = true,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(34, 0),
	Size = UDim2.new(1, -46, 1, 0),
	Parent = wheelSearch,
})
local wheelHint = label({
	FontFace = FONT.mono,
	TextSize = 10,
	TextColor3 = T.text3,
	TextXAlignment = Enum.TextXAlignment.Center,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromOffset(0, 250),
	Size = UDim2.fromOffset(320, 14),
	Parent = hubHolder,
})

local wheelOpen = false
local wheelMode = "list"
local listData, searchData = {}, {}
local page = 1
local searchPages, searchToken, searchLoading = nil, 0, false
local wheelSlots = {}
local chooseSlot, renderPage
local hoverToken = 0
local wheelFit = 1

for i = 1, 8 do
	local ang = math.rad(-90 + (i - 1) * 45)
	local b = mk("TextButton", {
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(math.cos(ang) * 136, math.sin(ang) * 136),
		Size = UDim2.fromOffset(76, 76),
		BackgroundColor3 = T.surface,
		Parent = hubHolder,
	}, { corner(18) })
	local st = stroke(BORDER.default)
	st.Parent = b
	shadow(b, "pop")
	shadow(b, "edge")
	local num = label({
		Text = tostring(i),
		FontFace = FONT.mono,
		TextSize = 10,
		TextColor3 = T.text3,
		Position = UDim2.fromOffset(9, 7),
		Size = UDim2.fromOffset(12, 12),
		ZIndex = 2,
		Parent = b,
	})
	local img = mk("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(52, 52),
		BackgroundTransparency = 1,
		Parent = b,
	})
	local empty = label({
		Text = "—",
		TextSize = 16,
		TextColor3 = T.text3,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		Parent = b,
	})
	local saved = mk("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 8),
		Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = T.accent,
		Visible = false,
		ZIndex = 2,
		Parent = b,
	}, { corner(4) })
	local sc = mk("UIScale", { Parent = b })
	wheelSlots[i] = { stroke = st, img = img, empty = empty, scale = sc, saved = saved, num = num }
	b.MouseEnter:Connect(function()
		local data = wheelMode == "search" and searchData or listData
		local e = data[(page - 1) * 8 + i]
		hubTitle.Text = e and e.name or L("wheel_empty")
		tween(st, { Color = T.accent, Transparency = 0 })
		tween(sc, { Scale = 1.08 }, 0.18, Enum.EasingStyle.Back)
		hoverToken += 1
		local my = hoverToken
		if e then
			task.spawn(function()
				local anim = emoteAnimation(e.id)
				if my == hoverToken and wheelOpen then
					preview:playAnim(anim)
				end
			end)
		end
	end)
	b.MouseLeave:Connect(function()
		hubTitle.Text = L(wheelMode == "search" and "wheel_search_title" or "wheel_title")
		tween(st, { Color = T.white, Transparency = BORDER.default })
		tween(sc, { Scale = 1 }, 0.15)
		hoverToken += 1
		local my = hoverToken
		task.delay(0.15, function()
			if my == hoverToken then
				preview:stopAnim()
			end
		end)
	end)
	b.MouseButton1Click:Connect(function()
		chooseSlot(i)
	end)
	b.MouseButton2Click:Connect(function()
		if wheelMode ~= "search" then
			return
		end
		local e = searchData[(page - 1) * 8 + i]
		if e then
			addEmoteToWheel(e.id, e.name)
			saved.Visible = true
		end
	end)
end

local function pageCount()
	local data = wheelMode == "search" and searchData or listData
	return math.max(1, math.ceil(#data / 8))
end

renderPage = function(animate)
	local data = wheelMode == "search" and searchData or listData
	for i, s in ipairs(wheelSlots) do
		local idx = (page - 1) * 8 + i
		local e = data[idx]
		s.img.Image = e and emoteThumb(e.id) or ""
		s.img.Visible = e ~= nil
		s.empty.Visible = e == nil
		s.num.Text = tostring(i)
		s.saved.Visible = e ~= nil and wheelMode == "search" and AC.HasEmote(e.id)
		s.stroke.Color, s.stroke.Transparency = T.white, BORDER.default
		if animate then
			s.scale.Scale = 0.6
			task.delay(i * 0.015, function()
				tween(s.scale, { Scale = 1 }, 0.28, Enum.EasingStyle.Back)
			end)
		end
	end
	local pc = pageCount()
	local more = wheelMode == "search" and searchPages and not searchPages.IsFinished
	pageLabel.Text = page .. "/" .. pc .. (more and "+" or "")
	prevBtn.Visible = page > 1
	nextBtn.Visible = page < pc or more
	hubTitle.Text = L(wheelMode == "search" and "wheel_search_title" or "wheel_title")
	wheelHint.Text = wheelMode == "search" and L("wheel_hint_search") or "1–8 · Q / E · ESC"
	local first = (page - 1) * 8
	for k = 1, 8 do
		local e = data[first + k]
		if e then
			task.spawn(emoteAnimation, e.id)
		end
	end
end

local function flip(delta)
	local pc = pageCount()
	local target = page + delta
	if target < 1 then
		return
	end
	if target > pc then
		if wheelMode == "search" and searchPages and not searchPages.IsFinished and not searchLoading then
			searchLoading = true
			local my = searchToken
			task.spawn(function()
				local ok = pcall(searchPages.AdvanceToNextPageAsync, searchPages)
				if ok and my == searchToken then
					for _, it in ipairs(searchPages:GetCurrentPage()) do
						table.insert(searchData, { id = it.Id, name = it.Name })
					end
					if math.ceil(#searchData / 8) >= target then
						page = target
					end
					renderPage(true)
				end
				searchLoading = false
			end)
		end
		return
	end
	page = target
	renderPage(true)
end
prevBtn.MouseButton1Click:Connect(function()
	flip(-1)
end)
nextBtn.MouseButton1Click:Connect(function()
	flip(1)
end)

local function wheelSearchRun(text)
	searchToken += 1
	local my = searchToken
	if not text:match("%S") then
		wheelMode, page = "list", 1
		renderPage(true)
		return
	end
	wheelMode, page, searchData, searchPages = "search", 1, {}, nil
	renderPage(false)
	task.spawn(function()
		local ok, pg = pcall(function()
			local p = CatalogSearchParams.new()
			p.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
			p.SearchKeyword = text
			return AvatarEditorService:SearchCatalog(p)
		end)
		if my ~= searchToken then
			return
		end
		if ok then
			searchPages = pg
			for _, it in ipairs(pg:GetCurrentPage()) do
				table.insert(searchData, { id = it.Id, name = it.Name })
			end
		end
		renderPage(true)
	end)
end

local typed = 0
wheelInput:GetPropertyChangedSignal("Text"):Connect(function()
	typed += 1
	local my = typed
	task.delay(0.25, function()
		if my == typed and wheelOpen then
			wheelSearchRun(wheelInput.Text)
		end
	end)
end)
wheelInput.Focused:Connect(function()
	tween(wsStroke, { Color = T.accent, Transparency = 0.4 })
end)
wheelInput.FocusLost:Connect(function()
	tween(wsStroke, { Color = T.white, Transparency = BORDER.default })
end)

local function closeWheel()
	if not wheelOpen then
		return
	end
	wheelOpen = false
	hoverToken += 1
	wheelInput:ReleaseFocus()
	tween(dim, { BackgroundTransparency = 1 }, 0.15)
	tween(hubScale, { Scale = wheelFit * 0.85 }, 0.12)
	task.delay(0.14, function()
		if not wheelOpen then
			wheelSg.Enabled = false
			preview:stopAnim()
		end
	end)
end

openWheel = function()
	listData = AC.GetWheelEmotes()
	wheelMode, page = "list", 1
	searchToken += 1
	wheelInput.Text = ""
	wheelInput.PlaceholderText = L("wheel_search")
	renderPage(true)
	wheelOpen = true
	wheelSg.Enabled = true
	local look = (AC.source and AC.source.model) or myLookModel()
	if preview.source ~= look then
		preview:set(look, 1.35)
	end
	preview:play()
	wheelFit = math.min(1, (wheelSg.AbsoluteSize.Y - 24) / 540)
	dim.BackgroundTransparency = 1
	tween(dim, { BackgroundTransparency = 0.55 }, 0.2)
	hubScale.Scale = wheelFit * 0.8
	tween(hubScale, { Scale = wheelFit }, 0.3, Enum.EasingStyle.Back)
end

chooseSlot = function(i)
	local data = wheelMode == "search" and searchData or listData
	local e = data[(page - 1) * 8 + i]
	closeWheel()
	if e then
		task.spawn(AC.PlayEmote, e.id)
	end
end
dim.MouseButton1Click:Connect(closeWheel)

local NUM_KEYS = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
}
connect(UserInputService.InputBegan, function(input, processed)
	local typing = UserInputService:GetFocusedTextBox() ~= nil
	if wheelOpen then
		if input.KeyCode == Enum.KeyCode.Escape then
			if wheelInput.Text ~= "" then
				wheelInput.Text = ""
			else
				closeWheel()
			end
		elseif not typing then
			if input.KeyCode == Enum.KeyCode.Period then
				closeWheel()
			elseif input.KeyCode == Enum.KeyCode.Q then
				flip(-1)
			elseif input.KeyCode == Enum.KeyCode.E then
				flip(1)
			elseif NUM_KEYS[input.KeyCode] then
				chooseSlot(NUM_KEYS[input.KeyCode])
			end
		end
		return
	end
	if not processed and not typing and customWheel and input.KeyCode == Enum.KeyCode.Period then
		openWheel()
	end
end)
connect(UserInputService.InputChanged, function(input)
	if wheelOpen and input.UserInputType == Enum.UserInputType.MouseWheel then
		flip(input.Position.Z > 0 and -1 or 1)
	end
end)
setNativeWheel(not customWheel)

return {
	rebuild = function()
		rebuildEmotes()
	end,
	destroy = function()
		wheelSg:Destroy()
		setNativeWheel(true)
	end,
}

end)()

local function refreshAll()
	refreshPreview()
	rebuildTiles()
	rebuildChips()
	emotes.rebuild()
end

AC.onChanged = refreshAll

local function setLang(code)
	AC.lang = code
	config.lang = code
	saveConfig()
	applyTranslations()
	sidePanel.relabel()
	refreshAll()
	task.defer(function()
		placeTabLine(true)
		settle()
	end)
end

local DISCORD_INVITE = "https://discord.gg/As2QHxxVjU"

local settingsUI = (function()

local SET_W = 252
local catcher = mk("TextButton", {
	Visible = false,
	Text = "",
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 44,
	Parent = sg,
})
local pop = mk("Frame", {
	Visible = false,
	Size = UDim2.fromOffset(SET_W, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundColor3 = T.raised,
	ZIndex = 45,
	Parent = sg,
}, { corner(12), stroke(BORDER.default), pad(6, 12, 8, 12), list(nil, 2) })
shadow(pop, "pop")
shadow(pop, "edge")
local popScale = mk("UIScale", { Parent = pop })
tr(eyebrow("", pop, { Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 1 }), "Text", "settings_title")

local function row(order, key)
	local r = mk("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = order, Parent = pop })
	tr(
		label({
			FontFace = FONT.medium,
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -112, 1, 0),
			Parent = r,
		}),
		"Text",
		key
	)
	return r
end

local function copyLink()
	if setclipboard and pcall(setclipboard, DISCORD_INVITE) then
		log(L("link_copied"), "success")
	end
end

local langRow = row(2, "language")
local langPick = mk("TextButton", {
	Text = "",
	AutoButtonColor = false,
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.fromScale(1, 0.5),
	Size = UDim2.fromOffset(0, 26),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = T.control,
	Parent = langRow,
}, { corner(7), pad(0, 8, 0, 10), list(Enum.FillDirection.Horizontal, 6, Enum.VerticalAlignment.Center) })
local langName = label({
	TextSize = 12,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 16),
	LayoutOrder = 1,
	Parent = langPick,
})
label({
	Text = "›",
	TextSize = 15,
	TextColor3 = T.text3,
	AutomaticSize = Enum.AutomaticSize.X,
	Size = UDim2.fromOffset(0, 16),
	LayoutOrder = 2,
	Parent = langPick,
})
local function langTitle()
	for _, lg in ipairs(LANGS) do
		if lg[1] == AC.lang then
			return lg[2]
		end
	end
	return AC.lang
end
langPick.MouseEnter:Connect(function()
	tween(langPick, { BackgroundColor3 = T.controlHover })
end)
langPick.MouseLeave:Connect(function()
	tween(langPick, { BackgroundColor3 = T.control })
end)
langPick.MouseButton1Click:Connect(function()
	local items = {}
	for _, lg in ipairs(LANGS) do
		local code, name = lg[1], lg[2]
		table.insert(items, {
			(code == AC.lang and "●  " or "    ") .. name,
			function()
				setLang(code)
				langName.Text = langTitle()
			end,
		})
	end
	openMenu(items)
end)

local introRow = row(3, "intro_anim")
local discordRow = row(4, "discord_notif")
local function placeSwitch(r, on, onChange)
	local old = r:FindFirstChild("Switch")
	if old then
		old:Destroy()
	end
	local sw = switch(on, onChange)
	sw.Name = "Switch"
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.Position = UDim2.fromScale(1, 0.5)
	sw.Parent = r
end

mk("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = T.white,
	BackgroundTransparency = BORDER.subtle,
	BorderSizePixel = 0,
	LayoutOrder = 5,
	Parent = pop,
})
local inviteBtn = mk("TextButton", {
	Text = DISCORD_INVITE:gsub("^https://", ""),
	FontFace = FONT.mono,
	TextSize = 10,
	TextColor3 = T.text3,
	TextXAlignment = Enum.TextXAlignment.Left,
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 24),
	LayoutOrder = 6,
	Parent = pop,
})
inviteBtn.MouseEnter:Connect(function()
	tween(inviteBtn, { TextColor3 = Color3.fromHex("5865F2") })
	showTooltip(L("copy_link"))
end)
inviteBtn.MouseLeave:Connect(function()
	tween(inviteBtn, { TextColor3 = T.text3 })
	hideTooltip()
end)
inviteBtn.MouseButton1Click:Connect(copyLink)

local function close()
	pop.Visible = false
	catcher.Visible = false
end
catcher.MouseButton1Click:Connect(close)
catcher.MouseButton2Click:Connect(close)

local function open()
	langName.Text = langTitle()
	placeSwitch(introRow, config.intro ~= false, function(v)
		config.intro = v
		saveConfig()
	end)
	placeSwitch(discordRow, config.discordNotif ~= false, function(v)
		config.discordNotif = v
		saveConfig()
	end)
	local box = sg.AbsoluteSize
	local rel = langBtn.AbsolutePosition - sg.AbsolutePosition
	local x = math.clamp(rel.X + langBtn.AbsoluteSize.X - SET_W, 8, math.max(box.X - SET_W - 8, 8))
	pop.Position = UDim2.fromOffset(x, rel.Y + langBtn.AbsoluteSize.Y + 8)
	catcher.Visible = true
	pop.Visible = true
	popScale.Scale = 0.94
	tween(popScale, { Scale = 1 }, 0.2, Enum.EasingStyle.Back)
	hideTooltip()
end

langBtn.MouseButton1Click:Connect(function()
	if pop.Visible then
		close()
	else
		open()
	end
end)
langBtn.MouseEnter:Connect(function()
	showTooltip(L("settings"))
end)
langBtn.MouseLeave:Connect(hideTooltip)

local function intro(onDone)
	local overlay = mk("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.black,
		BackgroundTransparency = 1,
		ZIndex = 80,
		Parent = sg,
	})
	local group = mk("CanvasGroup", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(380, 150),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		ZIndex = 81,
		Parent = overlay,
	})
	local scale = mk("UIScale", { Scale = 0.86, Parent = group })
	local brandLine = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 26),
		Size = UDim2.fromOffset(0, 46),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 82,
		Parent = group,
	}, { list(Enum.FillDirection.Horizontal, 14, Enum.VerticalAlignment.Center) })
	local logoId = asset(DATA_DIR .. "/assets/logo.png")
	if logoId then
		mk("ImageLabel", {
			Image = logoId,
			Size = UDim2.fromOffset(38, 43),
			BackgroundTransparency = 1,
			ZIndex = 83,
			Parent = brandLine,
		})
	end
	label({
		Text = "TZAR HUB",
		FontFace = FONT.semibold,
		TextSize = 36,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 44),
		LayoutOrder = 2,
		ZIndex = 83,
		Parent = brandLine,
	})
	local sub = label({
		Text = "AVATAR CHANGER",
		FontFace = FONT.mono,
		TextSize = 12,
		TextColor3 = T.text3,
		TextXAlignment = Enum.TextXAlignment.Center,
		MaxVisibleGraphemes = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 84),
		Size = UDim2.fromOffset(300, 16),
		ZIndex = 83,
		Parent = group,
	})
	local line = mk("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 112),
		Size = UDim2.fromOffset(0, 2),
		BackgroundColor3 = T.accent,
		BorderSizePixel = 0,
		ZIndex = 83,
		Parent = group,
	}, { corner(1) })

	tween(overlay, { BackgroundTransparency = 0.45 }, 0.35)
	tween(group, { GroupTransparency = 0 }, 0.4)
	tween(scale, { Scale = 1 }, 0.6, Enum.EasingStyle.Back)
	task.wait(0.3)
	tween(line, { Size = UDim2.fromOffset(190, 2) }, 0.7, Enum.EasingStyle.Quint)
	for i = 1, #sub.Text do
		sub.MaxVisibleGraphemes = i
		task.wait(0.03)
	end
	task.wait(0.55)
	tween(group, { GroupTransparency = 1 }, 0.35)
	tween(scale, { Scale = 1.06 }, 0.35)
	tween(overlay, { BackgroundTransparency = 1 }, 0.4)
	task.wait(0.25)
	onDone()
	task.wait(0.3)
	overlay:Destroy()
end

local function discord()
	toast(L("discord_text"), "discord", {
		{ L("copy_link"), copyLink, true },
		{
			L("dont_show"),
			function()
				config.discordNotif = false
				saveConfig()
			end,
		},
	}, 12)
end

return { intro = intro, discord = discord }

end)()

connect(RunService.RenderStepped, function(dt)
	if not sg.Enabled or not win.Visible then
		return
	end
	if mainScene.model and not spinning and not dragYaw then
		mainScene.yaw += dt * 0.35
		mainScene:frame()
	end
	if hoveredScene and hoveredScene.model then
		hoveredScene.yaw += dt * 1.4
		hoveredScene:frame()
	end
end)

do
	local copyPlayer = AC.CopyPlayer
	AC.CopyPlayer = function(plr)
		copyPlayer(plr)
		if AC.source and cleanLabel(AC.source.label) == plr.Name then
			AC.source.playerId = plr.UserId
			rebuildChips()
		end
	end
end

connect(Players.PlayerAdded, rebuildChips)
connect(Players.PlayerRemoving, function()
	task.defer(rebuildChips)
end)
connect(lp.CharacterAdded, function()
	task.delay(2.5, function()
		if not AC.alive then
			return
		end
		if not AC.source then
			lastPreviewModel = nil
			refreshAll()
		else
			emotes.rebuild()
		end
	end)
end)
connect(UserInputService.InputBegan, function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightShift then
		sg.Enabled = not sg.Enabled
		if sg.Enabled then
			popIn(if pill.Visible then pillScale else winScale)
		end
	end
end)

function AC.Destroy()
	AC.alive = false
	for _, c in ipairs(AC.conns) do
		c:Disconnect()
	end
	if sg then
		sg:Destroy()
	end
	emotes.destroy()
	for _, m in pairs(thumbCache) do
		if m then
			m:Destroy()
		end
	end
	if genv.AvatarChanger == AC then
		genv.AvatarChanger = nil
	end
end

refreshAll()
local function showWindow()
	if config.collapsed then
		setCollapsed(true, true)
	else
		win.Visible = true
		popIn(winScale)
		settle()
	end
	task.delay(0.05, function()
		selectTab(tabs[config.tab] and config.tab or "look", true)
	end)
end
local withIntro = config.intro ~= false
if withIntro then
	win.Visible = false
	task.spawn(settingsUI.intro, showWindow)
else
	showWindow()
end
if config.discordNotif ~= false then
	task.delay(withIntro and 2.4 or 0.8, settingsUI.discord)
end
if not config.firstRunDone then
	config.firstRunDone = true
	saveConfig()
	task.delay(withIntro and 3.2 or 1.6, function()
		toast(L("settings_hint"), "info", nil, 9)
	end)
end

end

buildUI()
log(L("ready"))
