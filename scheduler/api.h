struct sched_avg {
	u64				last_update_time;
	u32				period_contrib; /* pelt框架下，最新的一个窗口的实际时间，由于严格的1024*1024ns的窗口期，每次计算的时候无法保证最新的窗口时间的完整性 */
	u64				load_sum;
	u64				runnable_load_sum;
	u32				util_sum;
	unsigned long			load_avg;
	unsigned long			runnable_load_avg;
	unsigned long			util_avg;
}

struct cfs_rq {
	struct load_weight	load; /* 1: 汇集se->load, 随enqueue/dequeue变化, account_entity_dequeue */
	unsigned long		runnable_weight; /* 2: 同1, dequeue_runnable_load_avg */
	struct sched_avg	avg; {
		u64				load_sum; /* 5: 汇集了runnable & blocked的se_weight(se) * se->avg.load_sum */
		u64				runnable_load_sum; /* 3: 同2 */
		u32				util_sum;
		unsigned long			load_avg; /* 6: 同5, se->avg.load_avg */
		unsigned long			runnable_load_avg; /* 4: 同2 */
		unsigned long			util_avg;
	}
}

struct sched_entity {
	struct load_weight		load;
	unsigned long			runnable_weight;
	struct sched_avg		avg;
}

struct task_group {
	unsigned long		shares;
	atomic_long_t		load_avg ____cacheline_aligned;
}

/******************************************************************************/
/******************************************************************************/

/*
	将gcfs_rq的util_avg和util_sum信息propogate到cfs_rq中，se作为中转站，记录了上一次同步时的状态，所以该函数每次只需要增量更新
 */
static inline void update_tg_cfs_util(struct cfs_rq *cfs_rq, struct sched_entity *se, struct cfs_rq *gcfs_rq) {
	cfs_rq: se隶属的cfs_rq
	se: task_group在特定CPU上的sched_entity
	gcfs_rq: se负责管理的cfs_rq
}

/*
	如果se负责管理的cfs_rq的统计信息需要propagate的话，将相关的信息汇集到自己所隶属的cfs_rq上面，并且标记该cfs_rq的信息需要继续propagate
	这样的设计可以避免每次cfs_rq管理的se有更新的时候，就去做propagate，
 */
static inline int propagate_entity_load_avg(struct sched_entity *se) {
	se: task_group在特定CPU上的sched_entity，如果是普通的task的话，该函数直接返回
}

int __update_load_avg_blocked_se(u64 now, struct sched_entity *se)
{
	if (___update_load_sum(now, &se->avg, 0, 0, 0)) {
		___update_load_avg(&se->avg, se_weight(se), se_runnable(se));
	}
}

int __update_load_avg_se(u64 now, struct cfs_rq *cfs_rq, struct sched_entity *se)
{
	if (___update_load_sum(now, &se->avg, !!se->on_rq, !!se->on_rq, cfs_rq->curr == se)) {
		___update_load_avg(&se->avg, se_weight(se), se_runnable(se));
	}
}

int __update_load_avg_cfs_rq(u64 now, struct cfs_rq *cfs_rq)
{
	if (___update_load_sum(now, &cfs_rq->avg, scale_load_down(cfs_rq->load.weight), scale_load_down(cfs_rq->runnable_weight), cfs_rq->curr != NULL)) {
		___update_load_avg(&cfs_rq->avg, 1, 1);
	}
}

/* 更新se，se所隶属的cfs_rq，cfs_rq所隶属的task_group的负载信息 */
void update_load_avg(struct cfs_rq *cfs_rq, struct sched_entity *se, int flags)

/* 	1: 计算se所管理的cfs_rq在其所隶属的task_group中的load, runnable信息
	2: 以此作为se本身的weight和runnable_weight信息
	3: 更新se所隶属的cfs_rq的负载信息 */
void update_cfs_group(struct sched_entity *se)

void entity_tick(struct cfs_rq *cfs_rq, struct sched_entity *curr, int queued) {
	update_load_avg(cfs_rq, curr, UPDATE_TG);
	update_cfs_group(curr);
}

一般来说cfs_rq及其管理的sched_entity是相对稳定的，所以只需要在enqueue_entity/dequeue_entity把sched_entity的weight和runnable_weight分别通过account_entity_enqueue/dequeue和enqueue/dequeue_runnable_load_avg继承到所隶属的cfs_rq上即可。entity_tick时只需要直接调用update_load_avg来更新相关负载信息。
