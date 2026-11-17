-- DIGITAL SOLUTIONS: ampliacion del inventario de repuestos
-- Ejecutar en Supabase > SQL Editor > New query.
-- Conserva la tabla public.inventory y sus politicas RLS existentes.

alter table public.inventory
  add column if not exists part_number text,
  add column if not exists brand text,
  add column if not exists compatible_models text,
  add column if not exists supplier text,
  add column if not exists storage_location text,
  add column if not exists unit text not null default 'unidad',
  add column if not exists updated_at timestamptz not null default now();

create index if not exists inventory_sku_idx
  on public.inventory (sku)
  where sku is not null and sku <> '';

create index if not exists inventory_product_name_idx
  on public.inventory (product_name);

create or replace function public.set_inventory_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists inventory_updated_at on public.inventory;
create trigger inventory_updated_at
before update on public.inventory
for each row execute function public.set_inventory_updated_at();

comment on column public.inventory.part_number is 'Numero de parte del repuesto';
comment on column public.inventory.brand is 'Marca del repuesto o fabricante';
comment on column public.inventory.compatible_models is 'Marcas y modelos compatibles';
comment on column public.inventory.supplier is 'Proveedor del repuesto';
comment on column public.inventory.storage_location is 'Ubicacion fisica dentro del negocio';
comment on column public.inventory.unit is 'Unidad de control: unidad, par, paquete, etc.';
