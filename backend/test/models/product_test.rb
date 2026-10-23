require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def attrs(overrides = {})
    {
      catalog_number: 100,
      name: "Producto de prueba",
      category: "ostras",
      presentation: "Caja de prueba",
      unit: "unidad",
      net_price_clp: 1000,
      active: true
    }.merge(overrides)
  end

  test "los fixtures son válidos" do
    assert products(:filete).valid?
    assert products(:ostra).valid?
  end

  test "es válido con atributos correctos" do
    assert Product.new(attrs).valid?
  end

  test "la presentación es opcional" do
    assert Product.new(attrs(presentation: nil)).valid?
  end

  test "exige nombre" do
    assert_not Product.new(attrs(name: "")).valid?
  end

  test "exige un número de catálogo entero mayor que cero" do
    [ nil, 0, -1 ].each do |value|
      assert_not Product.new(attrs(catalog_number: value)).valid?, "debería rechazar #{value.inspect}"
    end
  end

  test "el número de catálogo es único" do
    duplicate = Product.new(attrs(catalog_number: products(:filete).catalog_number))
    assert_not duplicate.valid?
    assert duplicate.errors.of_kind?(:catalog_number, :taken)
  end

  test "la categoría debe estar en la lista" do
    assert_not Product.new(attrs(category: "otra")).valid?
    Product::CATEGORIES.each do |category|
      assert Product.new(attrs(category: category)).valid?, "debería aceptar #{category}"
    end
  end

  test "la unidad debe estar en la lista" do
    assert_not Product.new(attrs(unit: "litro")).valid?
    Product::UNITS.each do |unit|
      assert Product.new(attrs(unit: unit)).valid?, "debería aceptar #{unit}"
    end
  end

  test "el precio neto no puede ser negativo" do
    assert_not Product.new(attrs(net_price_clp: -1)).valid?
    assert Product.new(attrs(net_price_clp: 0)).valid?
  end

  test "calcula el precio con IVA redondeando el medio hacia arriba" do
    assert_equal 1250, Product.new(attrs(net_price_clp: 1050)).gross_price_clp
    assert_equal 119, Product.new(attrs(net_price_clp: 100)).gross_price_clp
    assert_equal 0, Product.new(attrs(net_price_clp: 0)).gross_price_clp
  end

  test "la base de datos rechaza precios negativos" do
    product = Product.new(attrs(net_price_clp: -1))
    assert_raises(ActiveRecord::StatementInvalid) { product.save!(validate: false) }
  end
end
