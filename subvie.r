# Definitionen ----
## Libraries ----
library(tidyverse)
library(ggraph)
library(tidygraph)

## Daten ----
# https://de.wikipedia.org/wiki/Liste_der_Wiener_U-Bahn-Stationen
subvie <- tribble(~ID, ~Name, ~Lage, ~Linie, ~Nachbar,
                  "LO", "Oberlaa", "Oberfläche", "U1", "LN",
                  "LN", "Neulaa", "Oberfläche", "U1", c("LO", "AL"),
                  "AL", "Alaudagasse", "Tunnel", "U1", c("LN", "AT"),
                  "AT", "Altes Landgut", "Tunnel", "U1", c("AL", "TO"),
                  "TO", "Troststraße", "Tunnel", "U1", c("AT", "RP"),
                  "RP", "Reumannplatz", "Tunnel", "U1", c("TO", "KE"),
                  "KE", "Keplerplatz", "Tunnel", "U1", c("RP", "SL"),
                  "SL", "Südtiroler Platz - Hauptbahnhof", "Tunnel", "U1", c("KE", "TA"),
                  "TA", "Taubstummengasse", "Tunnel", "U1", c("SL", "KP"),
                  "KP", "Karlsplatz", "Tunnel", "U1", c("TA", "SZ"),
                  "SZ", "Stephansplatz", "Tunnel", "U1", c("KP", "SP"),
                  "SP", "Schwedenplatz", "Tunnel", "U1", c("SZ", "NP"),
                  "NP", "Nestroyplatz", "Tunnel", "U1", c("PR", "SP"),
                  "PR", "Praterstern", "Tunnel", "U1", c("NP", "VS"),
                  "VS", "Vorgartenstraße", "Tunnel", "U1", c("PR", "DI"),
                  "DI", "Donauinsel", "Viadukt", "U1", c("VS", "KM"),
                  "KM", "Kaisermühlen / Vienna International Centre", "Viadukt", "U1", c("DI", "AD"),
                  "AD", "Alte Donau", "Viadukt", "U1", c("KM", "ZK"),
                  "ZK", "Kagran", "Viadukt", "U1", c("AD", "KT"),
                  "KT", "Kagraner Platz", "Tunnel", "U1", c("ZK", "RB"),
                  "RB", "Rennbahnweg", "Viadukt", "U1", c("KT", "AK"),
                  "AK", "Aderklaaer Straße", "Oberfläche", "U1", c("RB", "GF"),
                  "GF", "Großfeldsiedlung", "Tunnel", "U1", c("AK", "LU"),
                  "LU", "Leopoldau", "Oberfläche", "U1", "GF",
                  "EE", "Seestadt", "Viadukt", "U2", "AN",
                  "AN", "Aspern Nord", "Oberfläche", "U2", c("EE", "HU"),
                  "HU", "Hausfeldstraße", "Viadukt", "U2", c("AN", "AP"), # bis ca 2024
                  "AP", "Aspernstarße", "Viadukt", "U2", c("HU", "DP"),   # bis ca 2024
                  # "HU", "Hausfeldstraße", "Viadukt", "U2", c("AN", ""),        # ab ca 2024
                  # "", "An den alten Schanzen", "Viadukt", "U2", c("HU", "AP"), # ab ca 2024
                  # "AP", "Aspernstarße", "Viadukt", "U2", c("", "DP"),          # ab ca 2024
                  "DP", "Donauspital", "Viadukt", "U2", c("AP", "AR"),
                  "AR", "Hardeggasse", "Viadukt", "U2", c("DP", "SD"),
                  "SD", "Stadlau", "Viadukt", "U2", c("AR", "DT"),
                  "DT", "Donaustadtbrücke", "Viadukt", "U2", c("SD", "DM"),
                  "DM", "Donaumarina", "Viadukt", "U2", c("DT", "SW"),
                  "SW", "Stadion", "Viadukt", "U2", c("DM", "TR"),
                  "TR", "Krieau", "Viadukt", "U2", c("SW", "MS"),
                  "MS", "Messe-Prater", "Tunnel", "U2", c("TR", "PR"),
                  "PR", "Praterstern", "Tunnel", "U2", c("MS", "TB"),
                  "TB", "Taborstraße", "Tunnel", "U2", c("PR", "SR"),
                  "SR", "Schottenring", "Tunnel", "U2", c("TB", "SO"),
                  "SO", "Schottentor", "Tunnel", "U2", c("SR", "RH"),
                  "RH", "Rathaus", "Tunnel", "U2", c("SO", "VT"),         # Sperre 2021-2024, bis 2027
                  "VT", "Volkstheater", "Tunnel", "U2", c("RH", "BA"),    # Sperre 2021-2024, bis 2027
                  "BA", "Museumsquartier", "Tunnel", "U2", c("VT", "KP"), # Sperre 2021-2024, bis 2027
                  "KP", "Karlsplatz", "Tunnel", "U2", "BA",               # Sperre 2021-2024, bis 2027
                  # "RH", "Rathaus", "Tunnel", "U2", c("SO", "MA"),            # Inbetriebnahme 2027
                  # "MA", "Neubaugasse", "Tunnel", "U2", c("RH", "PG"),        # Inbetriebnahme 2027
                  # "PG", "Pilgramgasse", "Tunnel", "U2", c("MA", ""),         # Inbetriebnahme 2027
                  # "", "Reinprechtsdorfer Straße", "Tunnel", "U2", c("", ""), # Inbetriebnahme 2027
                  # "", "Matzleinsdorfer Platz", "Tunnel", "U2", c("", ""),    # Inbetriebnahme 2027
                  # "", "Gußriegelstraße", "", "U2", c("", ""),                # Inbetriebnahme 2027
                  # "", "Wienerberg", "", "U2", "",                            # Inbetriebnahme 2027
                  "OK", "Ottakring", "Viadukt", "U3", "KR",
                  "KR", "Kendlerstraße", "Tunnel", "U3", c("OK", "HH"),
                  "HH", "Hütteldorfer Straße", "Tunnel", "U3", c("KR", "JO"),
                  "JO", "Johnstraße", "Tunnel", "U3", c("HH", "SH"),
                  "SH", "Schweglerstraße", "Tunnel", "U3", c("JO", "WS"),
                  "WS", "Westbahnhof", "Tunnel", "U3", c("SH", "GZ"),
                  "GZ", "Zieglergasse", "Tunnel", "U3", c("WS", "MA"),
                  "MA", "Neubaugasse", "Tunnel", "U3", c("GZ", "VT"),
                  "VT", "Volkstheater", "Tunnel", "U3", c("HZ", "MA"),
                  "HZ", "Herrengasse", "Tunnel", "U3", c("VT", "SZ"),
                  "SZ", "Stephansplatz", "Tunnel", "U3", c("HZ", "SE"),
                  "SE", "Stubentor", "Tunnel", "U3", c("SZ", "LA"),
                  "LA", "Landstarße", "Tunnel", "U3", c("SE", "RG"),
                  "RG", "Rochusgasse", "Tunnel", "U3", c("LA", "KN"),
                  "KN", "Kardinal-Nagl-Platz", "Tunnel", "U3", c("RG", "SG"),
                  "SG", "Schlachthausgasse", "Tunnel", "U3", c("KN", "ED"),
                  "ED", "Erdberg", "Oberfläche", "U3", c("SG", "AW"),
                  "AW", "Gasometer", "Tunnel", "U3", c("ED", "PP"),
                  "PP", "Zippererstraße", "Tunnel", "U3", c("AW", "EK"),
                  "EK", "Enkplatz", "Tunnel", "U3", c("PP", "SA"),
                  "SA", "Simmering", "Tunnel", "U3", "EK",
                  "HF", "Hütteldorf", "Oberfläche", "U4", "OV",
                  "OV", "Ober St. Veit", "Einschnitt", "U4", c("HF", "UV"),
                  "UV", "Unter St. Veit", "Einschnitt", "U4", c("UV", "BR"),
                  "BR", "Braunschweiggasse", "Einschnitt", "U4", c("UV", "HI"),
                  "HI", "Hietzing", "Einschnitt", "U4", c("BR", "SB"),
                  "SB", "Schönbrunn", "Einschnitt", "U4", c("HI", "MH"),
                  "MH", "Meidling Hauptstarße", "Tunnel", "U4", c("SB", "LE"),
                  "LE", "Längenfeldgasse", "Tunnel", "U4", c("MH", "MG"),
                  "MG", "Margaretehgürtel", "Einschnitt", "U4", c("LE", "PG"),
                  "PG", "Pilgramgasse", "Einschnitt", "U4", c("MG", "KG"),
                  "KG", "Kettenbrückemngasse", "Einschnitt", "U4", c("PG", "KP"),
                  "KP", "Karlsplatz", "Tunnel", "U4", c("KG", "ST"),
                  "ST", "Stadtpark", "Einschnitt", "U4", c("KP", "LA"),
                  "LA", "Landstarße", "Tunnel", "U4", c("ST", "SP"),
                  "SP", "Schwedenplatz", "Galerie", "U4", c("LA", "SR"),
                  "SR", "Schottenring", "Galerie", "U4", c("SP", "RL"),
                  "RL", "Roßauer Lände", "Einschnitt", "U4", c("SR", "FB"),
                  "FB", "Friedensbrücke", "Oberfläche", "U4", c("RL", "AU"),
                  "AU", "Spittelau", "Oberfläche", "U4", c("FB", "HS"),
                  "HS", "Heiligenstadt", "Oberfläche", "U4", "AU",
                  # "", "Elterleinplatz", "", "U5", "MB",
                  # "MB", "Michelbeuern - Allgemeines Krankenhaus", "", "U5", c("", ""),
                  # "", "Arne-Karlsson-Park", "", "U5", c("BM", ""),
                  # "", "Frankplatz", "", "U5", c("", ""),
                  # "RH", "Rathaus", "Tunnel", "U5", c("", "VT"),
                  # "VT", "Volkstheater", "Tunnel", "U5", c("RH", "BA"),
                  # "BA", "Museumsquartier", "Tunnel", "U5", c("VT", "KP"),
                  # "KP", "Karlsplatz", "Tunnel", "U5", "BA",
                  "HT", "Siebenhirten", "Viadukt", "U6", "PF",
                  "PF", "Perfektastraße", "Viadukt", "U6", c("HT", "ES"),
                  "ES", "Erlaaer Straße", "Viadukt", "U6", c("PF", "AE"),
                  "AE", "Alterlaa", "Viadukt", "U6", c("ES", "PW"),
                  "PW", "Am Schöpfwerk", "Viadukt", "U6", c("AE", "TE"),
                  "TE", "Tscherttegasse", "Oberfläche", "U6", c("PW", "PH"),
                  "PH", "Bahnhof Meidling", "Tunnel", "U6", c("TE", "NH"),
                  "NH", "Niederhofstarße", "Tunnel", "U6", c("PH", "LE"),
                  "LE", "Längenfeldgasse", "Tunnel", "U6", c("NH", "GU"),
                  "GU", "Gumpendorfer Straße", "Viadukt", "U6", c("LE", "WS"),
                  "WS", "Westbahnhof", "Tunnel", "U6", c("GU", "BU"),
                  "BU", "Burggasse - Stadthalle", "Einschnitt", "U6", c("WS", "TS"),
                  "TS", "Thaliastraße", "Viadukt", "U6", c("BU", "JS"),
                  "JS", "Josefstädter Straße", "Viadukt", "U6", c("TS", "AS"),
                  "AS", "Alser Straße", "Viadukt", "U6", c("JS", "MB"),
                  "MB", "Michelbeuern . Allgemeines Krankenhaus", "Oberfläche", "U6", c("AS", "WA"),
                  "WA", "Währinger Straße - Volksoper", "Viadukt", "U6", c("MB", "NS"),
                  "NS", "Nußdorfer Straße", "Viadukt", "U6", c("WA", "AU"),
                  "AU", "Spittelau", "Viadukt", "U6", c("NS", "JG"),
                  "JG", "Jägerstraße", "Tunnel", "U6", c("AU", "DS"),
                  "DS", "Dresdner Starße", "Tunnel", "U6", c("JG", "HK"),
                  "HK", "Handelskai", "Viadukt", "U6", c("DS", "ND"),
                  "ND", "Neue Donau", "Viadukt", "U6", c("HK", "FL"),
                  "FL", "Floridsdorf", "Tunnel", "U6", "ND"
                  )

# Verarbeitung ----
## Knoten ----
subvie_nodes <- subvie %>% 
  select(ID:Linie) %>% 
  nest(data = c(Lage, Linie)) %>% 
  mutate(Lage = map_chr(data, ~paste(sort(unique(.$Lage)), collapse = "/")),
         Linie = map_chr(data, ~paste(sort(.$Linie), collapse = "/"))) %>% 
  select(-data)

## Kanten ----
subvie_edges <- subvie %>% 
  select(ID, Nachbar, Linie) %>% 
  unnest(Nachbar)
# %>%
#   mutate(map2_df(.x = ID, .y = Nachbar, .f = ~sort(c(.x, .y)) %>% set_names(c("from", "to")))) %>%
#   select(-ID, -Nachbar) %>%
#   unique()

## Graph ----
subvie_graph <- tbl_graph(edges = subvie_edges) %>%
  left_join(subvie_nodes, by = c("name" = "ID"))

# Plot ----
ggraph(subvie_graph, layout = "stress") +
  geom_edge_link(mapping = aes(edge_colour = Linie), edge_width = 2.5) +
  # geom_node_point() +
  geom_node_label(mapping = aes(label = name), size = 2, alpha = .75) + #, colour = Lage
  scale_color_brewer(palette = "Dark2") +
  scale_edge_colour_manual(values = c("U1" = "red", "U2" = "violet", "U3" = "orange", "U4" = "forestgreen", "U5" = "turquois", "U6" = "brown"))
