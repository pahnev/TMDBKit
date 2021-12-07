//
//  File.swift
//  
//
//  Created by Pahnev, Kirill on 7.12.2021.
//

import Foundation

public struct WatchProviderResponse: CodableEquatable {
    public let id: Int
    public let results: Results?
}

public struct WatchProvider: CodableEquatable {
    public let displayPriority: Int
    public let logoPath: String
    public let providerId: Int
    public let providerName: String
}

public struct ProviderResult: CodableEquatable {
    public let link: String?
    public let buy: [WatchProvider]?
    public let rent: [WatchProvider]?
    public let flatrate: [WatchProvider]?
}

public struct Results: CodableEquatable {
    public let ar, at, au, be, bg, bo, br, ca, ch, cl, co, cr, cz,
        de, dk, ec, ee, es, fi, fr, gb, gr, gt, hk, hn, hu,
        id, ie, iN, it, jp, kr, lt, lv, mx, my,
        nl, no, nz, pe, ph, pl, pt, py, ro, ru, se,
        sg, th, tr, us, ve, za: ProviderResult?

    enum CodingKeys: String, CodingKey {
        case ar = "AR"
        case at = "AT"
        case au = "AU"
        case be = "BE"
        case bg = "BG"
        case bo = "BO"
        case br = "BR"
        case ca = "CA"
        case ch = "CH"
        case cl = "CL"
        case co = "CO"
        case cr = "CR"
        case cz = "CZ"
        case de = "DE"
        case dk = "DK"
        case ec = "EC"
        case ee = "EE"
        case es = "ES"
        case fi = "FI"
        case fr = "FR"
        case gb = "GB"
        case gr = "GR"
        case gt = "GT"
        case hk = "HK"
        case hn = "HN"
        case hu = "HU"
        case id = "ID"
        case ie = "IE"
        case iN = "IN"
        case it = "IT"
        case jp = "JP"
        case kr = "KR"
        case lt = "LT"
        case lv = "LV"
        case mx = "MX"
        case my = "MY"
        case nl = "NL"
        case no = "NO"
        case nz = "NZ"
        case pe = "PE"
        case ph = "PH"
        case pl = "PL"
        case pt = "PT"
        case py = "PY"
        case ro = "RO"
        case ru = "RU"
        case se = "SE"
        case sg = "SG"
        case th = "TH"
        case tr = "TR"
        case us = "US"
        case ve = "VE"
        case za = "ZA"
    }
}
