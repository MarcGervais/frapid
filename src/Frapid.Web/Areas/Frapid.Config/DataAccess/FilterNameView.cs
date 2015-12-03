// ReSharper disable All

using System.Collections.Generic;
using System.Data;
using System.Linq;
using Frapid.DataAccess;
using Frapid.DbPolicy;
using NPoco;
using Serilog;

namespace Frapid.Config.DataAccess
{
    /// <summary>
    ///     Provides simplified data access features to perform SCRUD operation on the database view "core.filter_name_view".
    /// </summary>
    public class FilterNameView : DbAccess, IFilterNameViewRepository
    {
        /// <summary>
        ///     The schema of this view. Returns literal "core".
        /// </summary>
        public override string _ObjectNamespace => "core";

        /// <summary>
        ///     The schema unqualified name of this view. Returns literal "filter_name_view".
        /// </summary>
        public override string _ObjectName => "filter_name_view";

        /// <summary>
        ///     Login id of application user accessing this view.
        /// </summary>
        public long _LoginId { get; set; }

        /// <summary>
        ///     User id of application user accessing this table.
        /// </summary>
        public int _UserId { get; set; }

        /// <summary>
        ///     The name of the database on which queries are being executed to.
        /// </summary>
        public string _Catalog { get; set; }

        /// <summary>
        ///     Performs SQL count on the view "core.filter_name_view".
        /// </summary>
        /// <returns>Returns the number of rows of the view "core.filter_name_view".</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public long Count()
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return 0;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to count entity \"FilterNameView\" was denied to the user with Login ID {LoginId}",
                        this._LoginId);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            const string sql = "SELECT COUNT(*) FROM core.filter_name_view;";
            return Factory.Scalar<long>(this._Catalog, sql);
        }

        /// <summary>
        ///     Executes a select query on the view "core.filter_name_view" to return all instances of the "FilterNameView" class.
        /// </summary>
        /// <returns>Returns a non-live, non-mapped instances of "FilterNameView" class.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public IEnumerable<Entities.FilterNameView> Get()
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return null;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.ExportData, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to the export entity \"FilterNameView\" was denied to the user with Login ID {LoginId}",
                        this._LoginId);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            const string sql = "SELECT * FROM core.filter_name_view ORDER BY 1;";
            return Factory.Get<Entities.FilterNameView>(this._Catalog, sql);
        }

        /// <summary>
        ///     Performs a select statement on the view "core.filter_name_view" producing a paginated result of 10.
        /// </summary>
        /// <returns>Returns the first page of collection of "FilterNameView" class.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public IEnumerable<Entities.FilterNameView> GetPaginatedResult()
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return null;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to the first page of the entity \"FilterNameView\" was denied to the user with Login ID {LoginId}.",
                        this._LoginId);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            const string sql = "SELECT * FROM core.filter_name_view ORDER BY 1 LIMIT 10 OFFSET 0;";
            return Factory.Get<Entities.FilterNameView>(this._Catalog, sql);
        }

        /// <summary>
        ///     Performs a select statement on the view "core.filter_name_view" producing a paginated result of 10.
        /// </summary>
        /// <param name="pageNumber">Enter the page number to produce the paginated result.</param>
        /// <returns>Returns collection of "FilterNameView" class.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public IEnumerable<Entities.FilterNameView> GetPaginatedResult(long pageNumber)
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return null;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to Page #{Page} of the entity \"FilterNameView\" was denied to the user with Login ID {LoginId}.",
                        pageNumber, this._LoginId);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            long offset = (pageNumber - 1)*10;
            const string sql = "SELECT * FROM core.filter_name_view ORDER BY 1 LIMIT 10 OFFSET @0;";

            return Factory.Get<Entities.FilterNameView>(this._Catalog, sql, offset);
        }

        /// <summary>
        ///     Performs a filtered count on view "core.filter_name_view".
        /// </summary>
        /// <param name="filterName">The named filter.</param>
        /// <returns>Returns number of rows of "FilterNameView" class using the filter.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public long CountFiltered(string filterName)
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return 0;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to count entity \"FilterNameView\" was denied to the user with Login ID {LoginId}. Filter: {Filter}.",
                        this._LoginId, filterName);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            List<Frapid.DataAccess.Filter> filters = this.GetFilters(this._Catalog, filterName);
            Sql sql = Sql.Builder.Append("SELECT COUNT(*) FROM core.filter_name_view WHERE 1 = 1");
            Frapid.DataAccess.FilterManager.AddFilters(ref sql, new Entities.FilterNameView(), filters);

            return Factory.Scalar<long>(this._Catalog, sql);
        }

        /// <summary>
        ///     Performs a filtered select statement on view "core.filter_name_view" producing a paginated result of 10.
        /// </summary>
        /// <param name="pageNumber">
        ///     Enter the page number to produce the paginated result. If you provide a negative number, the
        ///     result will not be paginated.
        /// </param>
        /// <param name="filterName">The named filter.</param>
        /// <returns>Returns collection of "FilterNameView" class.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public IEnumerable<Entities.FilterNameView> GetFiltered(long pageNumber, string filterName)
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return null;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to Page #{Page} of the filtered entity \"FilterNameView\" was denied to the user with Login ID {LoginId}. Filter: {Filter}.",
                        pageNumber, this._LoginId, filterName);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            List<Frapid.DataAccess.Filter> filters = this.GetFilters(this._Catalog, filterName);

            long offset = (pageNumber - 1)*10;
            Sql sql = Sql.Builder.Append("SELECT * FROM core.filter_name_view WHERE 1 = 1");

            Frapid.DataAccess.FilterManager.AddFilters(ref sql, new Entities.FilterNameView(), filters);

            sql.OrderBy("1");

            if (pageNumber > 0)
            {
                sql.Append("LIMIT @0", 10);
                sql.Append("OFFSET @0", offset);
            }

            return Factory.Get<Entities.FilterNameView>(this._Catalog, sql);
        }

        public List<Frapid.DataAccess.Filter> GetFilters(string catalog, string filterName)
        {
            const string sql =
                "SELECT * FROM core.filters WHERE object_name='core.filter_name_view' AND lower(filter_name)=lower(@0);";
            return Factory.Get<Frapid.DataAccess.Filter>(catalog, sql, filterName).ToList();
        }

        /// <summary>
        ///     Performs a filtered count on view "core.filter_name_view".
        /// </summary>
        /// <param name="filters">The list of filter conditions.</param>
        /// <returns>Returns number of rows of "FilterNameView" class using the filter.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public long CountWhere(List<Frapid.DataAccess.Filter> filters)
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return 0;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to count entity \"FilterNameView\" was denied to the user with Login ID {LoginId}. Filters: {Filters}.",
                        this._LoginId, filters);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            Sql sql = Sql.Builder.Append("SELECT COUNT(*) FROM core.filter_name_view WHERE 1 = 1");
            Frapid.DataAccess.FilterManager.AddFilters(ref sql, new Entities.FilterNameView(), filters);

            return Factory.Scalar<long>(this._Catalog, sql);
        }

        /// <summary>
        ///     Performs a filtered select statement on view "core.filter_name_view" producing a paginated result of 10.
        /// </summary>
        /// <param name="pageNumber">
        ///     Enter the page number to produce the paginated result. If you provide a negative number, the
        ///     result will not be paginated.
        /// </param>
        /// <param name="filters">The list of filter conditions.</param>
        /// <returns>Returns collection of "FilterNameView" class.</returns>
        /// <exception cref="UnauthorizedException">
        ///     Thown when the application user does not have sufficient privilege to perform
        ///     this action.
        /// </exception>
        public IEnumerable<Entities.FilterNameView> GetWhere(long pageNumber, List<Frapid.DataAccess.Filter> filters)
        {
            if (string.IsNullOrWhiteSpace(this._Catalog))
            {
                return null;
            }

            if (!this.SkipValidation)
            {
                if (!this.Validated)
                {
                    this.Validate(AccessTypeEnum.Read, this._LoginId, this._Catalog, false);
                }
                if (!this.HasAccess)
                {
                    Log.Information(
                        "Access to Page #{Page} of the filtered entity \"FilterNameView\" was denied to the user with Login ID {LoginId}. Filters: {Filters}.",
                        pageNumber, this._LoginId, filters);
                    throw new UnauthorizedException("Access is denied.");
                }
            }

            long offset = (pageNumber - 1)*10;
            Sql sql = Sql.Builder.Append("SELECT * FROM core.filter_name_view WHERE 1 = 1");

            Frapid.DataAccess.FilterManager.AddFilters(ref sql, new Entities.FilterNameView(), filters);

            sql.OrderBy("1");

            if (pageNumber > 0)
            {
                sql.Append("LIMIT @0", 10);
                sql.Append("OFFSET @0", offset);
            }

            return Factory.Get<Entities.FilterNameView>(this._Catalog, sql);
        }
    }
}