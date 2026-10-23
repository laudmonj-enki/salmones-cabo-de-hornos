class Product < ApplicationRecord
  IVA_PERCENT = 19

  CATEGORIES = %w[
    salmon_filetes_hon
    salmon_porciones_trozos
    ahumados
    elaborados
    crustaceos
    mariscos
    pescados
    ostras
  ].freeze

  UNITS = %w[kg unidad frasco].freeze

  validates :catalog_number, presence: true,
                             numericality: { only_integer: true, greater_than: 0 },
                             uniqueness: true
  validates :name, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :unit, inclusion: { in: UNITS }
  validates :net_price_clp, presence: true,
                            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [ true, false ] }

  # Precio con IVA en pesos enteros. Se calcula, no se guarda.
  # Con enteros: neto * 119 / 100, redondeando el medio hacia arriba.
  def gross_price_clp
    return nil if net_price_clp.nil?

    (net_price_clp * (100 + IVA_PERCENT) + 50) / 100
  end
end
