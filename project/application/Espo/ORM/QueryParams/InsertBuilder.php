<?php
/************************************************************************
 * This file is part of EspoCRM.
 *
 * EspoCRM - Open Source CRM application.
 * Copyright (C) 2014-2020 Yuri Kuznetsov, Taras Machyshyn, Oleksiy Avramenko
 * Website: https://www.espocrm.com
 *
 * EspoCRM is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * EspoCRM is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with EspoCRM. If not, see http://www.gnu.org/licenses/.
 *
 * The interactive user interfaces in modified source and object code versions
 * of this program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU General Public License version 3.
 *
 * In accordance with Section 7(b) of the GNU General Public License version 3,
 * these Appropriate Legal Notices must retain the display of the "EspoCRM" word.
 ************************************************************************/

namespace Espo\ORM\QueryParams;

class InsertBuilder implements Builder
{
    use BaseBuilderTrait;

    protected $params = [];

    /**
     * Build a INSERT query.
     */
    public function build() : Insert
    {
        return Insert::fromRaw($this->params);
    }

    /**
     * Clone an existing query for a subsequent modifying and building.
     */
    public function clone(Insert $query) : self
    {
        $this->cloneInternal($query);
    }

    /**
     * Into what entity type to insert.
     */
    public function into(string $entityType) : self
    {
        $this->params['into'] = $entityType;

        return $this;
    }

    /**
     * What columns to set with values. A list of columns.
     */
    public function columns(array $columns) : self
    {
        $this->params['columns'] = $columns;

        return $this;
    }

    /**
     * What values to insert. A key-value map or a list of key-value maps.
     */
    public function values(array $values) : self
    {
        $this->params['values'] = $values;

        return $this;
    }

    /**
     * Values to set on duplicate key. A key-value map.
     */
    public function updateSet(array $updateSet) : self
    {
        $this->params['updateSet'] = $updateSet;

        return $this;
    }

    /**
     * For a mass insert by a select sub-query.
     */
    public function valuesQuery(Selecting $query) : self
    {
        $this->params['valuesQuery'] = $query;

        return $this;
    }
}
