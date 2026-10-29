<?php

namespace VanguardLTE\Providers;

use Carbon\Carbon;
use VanguardLTE\Repositories\Activity\ActivityRepository;
use VanguardLTE\Repositories\Activity\EloquentActivity;
use VanguardLTE\Repositories\Country\CountryRepository;
use VanguardLTE\Repositories\Country\EloquentCountry;
use VanguardLTE\Repositories\Permission\EloquentPermission;
use VanguardLTE\Repositories\Permission\PermissionRepository;
use VanguardLTE\Repositories\Session\DbSession;
use VanguardLTE\Repositories\Session\EloquentSession;
use VanguardLTE\Repositories\User\EloquentUser;
use VanguardLTE\Repositories\User\UserRepository;
use Illuminate\Support\ServiceProvider;

use Illuminate\Support\Collection;
use Illuminate\Pagination\Paginator;
use Illuminate\Pagination\LengthAwarePaginator;

// Added to fix redirect loop
use Illuminate\Support\Facades\URL;
use Illuminate\Http\Request;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Carbon::setLocale(config('app.locale'));
        config(['app.name' => settings('app_name')]);
        \Illuminate\Database\Schema\Builder::defaultStringLength(191);

        // Added to fix 10 internal redirects loop on Render HTTPS proxy
        URL::forceScheme('https');
        Request::setTrustedProxies(
            ['*'],
            Request::HEADER_X_FORWARDED_FOR | 
            Request::HEADER_X_FORWARDED_HOST | 
            Request::HEADER_X_FORWARDED_PORT | 
            Request::HEADER_X_FORWARDED_PROTO
        );

        /*
        if($this->app->environment('production')) {
            \URL::forceScheme('http');
        }
        */

        Paginator::useBootstrap();

        // Enable pagination
        /*
        if (!Collection::hasMacro('paginate')) {
            Collection::macro('paginate',
                function ($perPage = 15, $page = null, $options = []) {
                    $page = $page ?: (Paginator::resolveCurrentPage() ?: 1);
                    return (new LengthAwarePaginator(
                        $this->forPage($page, $perPage)->values()->all(),
                        $this->count(), $perPage, $page, $options
                    ))->withPath('');
                });
        }
        */
    }

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(UserRepository::class, EloquentUser::class);
        $this->app->singleton(ActivityRepository::class, EloquentActivity::class);
        $this->app->singleton(PermissionRepository::class, EloquentPermission::class);
        $this->app->singleton(SessionRepository::class, DbSession::class);
        $this->app->singleton(CountryRepository::class, EloquentCountry::class);

        if ($this->app->environment('local')) {
            //$this->app->register(\Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider::class);
            //$this->app->register(\Barryvdh\Debugbar\ServiceProvider::class);
        }
    }
}
