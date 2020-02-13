#!/bin/bash
if (($(id -u) != 0)) ; then echo "please run as root"; exit ; fi

#modify following variables
module="ext4"
parameters=(
	#dumpstack, event, filter fields...
	"1 ext4_allocate_blocks"
	"1 ext4_allocate_inode"
	"1 ext4_alloc_da_blocks"
	"1 ext4_begin_ordered_truncate"
	"1 ext4_collapse_range"
	"1 ext4_da_release_space"
	"1 ext4_da_reserve_space"
	"1 ext4_da_update_reserve_space"
	"1 ext4_da_write_begin"
	"1 ext4_da_write_end"
	"1 ext4_da_write_pages"
	"1 ext4_da_write_pages_extent"
	"1 ext4_direct_IO_enter"
	"1 ext4_direct_IO_exit"
	"1 ext4_discard_blocks"
	"1 ext4_discard_preallocations"
	"1 ext4_drop_inode"
	"1 ext4_es_cache_extent"
	"1 ext4_es_find_delayed_extent_range_enter"
	"1 ext4_es_find_delayed_extent_range_exit"
	"1 ext4_es_insert_extent"
	"1 ext4_es_lookup_extent_enter"
	"1 ext4_es_lookup_extent_exit"
	"1 ext4_es_remove_extent"
	"1 ext4_es_shrink"
	"1 ext4_es_shrink_count"
	"1 ext4_es_shrink_scan_enter"
	"1 ext4_es_shrink_scan_exit"
	"1 ext4_evict_inode"
	"1 ext4_ext_convert_to_initialized_enter"
	"1 ext4_ext_convert_to_initialized_fastpath"
	"1 ext4_ext_handle_unwritten_extents"
	"1 ext4_ext_in_cache"
	"1 ext4_ext_load_extent"
	"1 ext4_ext_map_blocks_enter"
	"1 ext4_ext_map_blocks_exit"
	"1 ext4_ext_put_in_cache"
	"1 ext4_ext_remove_space"
	"1 ext4_ext_remove_space_done"
	"1 ext4_ext_rm_idx"
	"1 ext4_ext_rm_leaf"
	"1 ext4_ext_show_extent"
	"1 ext4_fallocate_enter"
	"1 ext4_fallocate_exit"
	"1 ext4_find_delalloc_range"
	"1 ext4_forget"
	"1 ext4_free_blocks"
	"1 ext4_free_inode"
	"1 ext4_fsmap_high_key"
	"1 ext4_fsmap_low_key"
	"1 ext4_fsmap_mapping"
	"1 ext4_getfsmap_high_key"
	"1 ext4_getfsmap_low_key"
	"1 ext4_getfsmap_mapping"
	"1 ext4_get_implied_cluster_alloc_exit"
	"1 ext4_get_reserved_cluster_alloc"
	"1 ext4_ind_map_blocks_enter"
	"1 ext4_ind_map_blocks_exit"
	"1 ext4_insert_range"
	"1 ext4_invalidatepage"
	"1 ext4_journalled_invalidatepage"
	"1 ext4_journalled_write_end"
	"1 ext4_journal_start"
	"1 ext4_journal_start_reserved"
	"1 ext4_load_inode"
	"1 ext4_load_inode_bitmap"
	"1 ext4_mark_inode_dirty"
	"1 ext4_mballoc_alloc"
	"1 ext4_mballoc_discard"
	"1 ext4_mballoc_free"
	"1 ext4_mballoc_prealloc"
	"1 ext4_mb_bitmap_load"
	"1 ext4_mb_buddy_bitmap_load"
	"1 ext4_mb_discard_preallocations"
	"1 ext4_mb_new_group_pa"
	"1 ext4_mb_new_inode_pa"
	"1 ext4_mb_release_group_pa"
	"1 ext4_mb_release_inode_pa"
	"1 ext4_other_inode_update_time"
	"1 ext4_punch_hole"
	"1 ext4_read_block_bitmap_load"
	"1 ext4_readpage"
	"1 ext4_releasepage"
	"1 ext4_remove_blocks"
	"1 ext4_request_blocks"
	"1 ext4_request_inode"
	"1 ext4_sync_file_enter"
	"1 ext4_sync_file_exit"
	"1 ext4_sync_fs"
	"1 ext4_trim_all_free"
	"1 ext4_trim_extent"
	"1 ext4_truncate_enter"
	"1 ext4_truncate_exit"
	"1 ext4_unlink_enter"
	"1 ext4_unlink_exit"
	"1 ext4_write_begin"
	"1 ext4_write_end"
	"1 ext4_writepage"
	"1 ext4_writepages"
	"1 ext4_writepages_result"
	"1 ext4_zero_range"
)

cd /sys/kernel/debug/tracing
if [[ "$1" == "1" ]]; then
	echo > trace
	echo 1 > tracing_on
elif [[ "$1" == "0" ]]; then
	echo 0 > tracing_on
	cat trace > /tmp/trace
else
	echo "usage: 1/0"
fi

event=""
filter=""

#enable
for ps in "${parameters[@]}"; do
	i=0
	event=""
	filter=""
	stack=0
	for p in $ps; do
		if ((i==0)) ; then
			stack=$p
		elif ((i==1)) ; then
			event=$p
		else
			if ((i>2)) ; then
				filter="${filter} || "
			fi
			filter="${filter}$p == $target"
		fi
		((i++))
	done

	if [[ "$1" == "1" ]]; then
		echo 1 > events/$module/$event/enable
		if [[ "$filter" != "" ]] ; then
			echo "$filter" > events/$module/$event/filter
			if (( $stack == 1 )) ; then echo "stacktrace if ($filter)" > events/$module/$event/trigger ; fi
			#cat events/$module/$event/filter
			#cat events/$module/$event/trigger
		else
			if (( $stack == 1 )) ; then echo "stacktrace" > events/$module/$event/trigger ; fi
			#cat events/$module/$event/trigger
		fi
	else
		echo 0 > events/$module/$event/enable
		if [[ "$filter" != "" ]] ; then
			echo 0 > events/$module/$event/filter
			if (( $stack == 1 )) ; then echo "!stacktrace if ($filter)" > events/$module/$event/trigger ; fi
		else
			if (( $stack == 1 )) ; then echo "!stacktrace" > events/$module/$event/trigger ; fi
		fi
	fi
done
