import { describe, it, expect } from 'vitest'
import { maintenantParis, lendemain, prochainePriere, formatCompteARebours } from '../horairesPriere'
import { extraireConfData } from '../../api/horaires.js'

// Calendrier minimal : [fajr, chourouk, dhuhr, asr, maghrib, isha]
const calendar = Array.from({ length: 12 }, () => ({}))
calendar[9]['4'] = ['06:51', '07:59', '13:51', '16:56', '19:34', '20:40']
calendar[9]['5'] = ['06:52', '08:00', '13:51', '16:55', '19:32', '20:38']
calendar[9]['31'] = ['06:30', '07:40', '12:50', '15:50', '18:20', '19:30']
calendar[10]['1'] = ['06:31', '07:41', '12:50', '15:49', '18:19', '19:29']
calendar[11]['31'] = ['07:00', '08:30', '13:10', '15:30', '17:40', '19:00']
calendar[0]['1'] = ['07:01', '08:31', '13:11', '15:31', '17:41', '19:01']

const at = (mois, jour, hh, mm, annee = 2026) => ({ annee, mois, jour, secondes: hh * 3600 + mm * 60 })

describe('Horaires de prière', () => {
  it('trouve la prochaine prière de la journée', () => {
    const p = prochainePriere(calendar, at(10, 4, 15, 0))
    expect(p.key).toBe('asr')
    expect(p.heure).toBe('16:56')
    expect(p.dansSecondes).toBe(116 * 60)
  })

  it('après Isha, la prochaine est le Fajr du lendemain', () => {
    const p = prochainePriere(calendar, at(10, 4, 21, 0))
    expect(p).toMatchObject({ key: 'fajr', heure: '06:52', demain: true })
    expect(p.dansSecondes).toBe(3 * 3600 + 6 * 3600 + 52 * 60)
  })

  it('gère la fin du mois et la fin de l\'année', () => {
    expect(prochainePriere(calendar, at(10, 31, 22, 0)).heure).toBe('06:31')
    expect(lendemain({ annee: 2026, mois: 12, jour: 31 })).toEqual({ annee: 2027, mois: 1, jour: 1 })
    expect(prochainePriere(calendar, at(12, 31, 22, 0)).heure).toBe('07:01')
  })

  it('utilise l\'heure de Paris, y compris au passage à l\'heure d\'hiver', () => {
    // 25 octobre 2026, 02:30 UTC = 03:30 heure de Paris (heure d'hiver, UTC+1)
    expect(maintenantParis(new Date('2026-10-25T02:30:00Z'))).toMatchObject({ mois: 10, jour: 25, secondes: 3 * 3600 + 30 * 60 })
    // 22:30 UTC le 4 octobre = 00:30 le 5 à Paris (heure d'été, UTC+2)
    expect(maintenantParis(new Date('2026-10-04T22:30:00Z'))).toMatchObject({ jour: 5, secondes: 30 * 60 })
  })

  it('formate le compte à rebours', () => {
    expect(formatCompteARebours(2 * 3600 + 5 * 60 + 9)).toBe('2 h 05 min')
    expect(formatCompteARebours(4 * 60 + 7)).toBe('4 min 07 s')
  })

  it('lit le calendrier dans la page Mawaqit', () => {
    const html = `<script>var confData = {"jumua":"13:00","timezone":"Europe\\/Paris","calendar":${JSON.stringify(calendar)}};\n</script>`
    const d = extraireConfData(html)
    expect(d.source).toBe('mawaqit')
    expect(d.jumua).toBe('13:00')
    expect(d.calendar[9]['4'][0]).toBe('06:51')
  })
})
